
#' /////////  prepare data for graph-AI model  ///////////

#' @param adjs constructed graph
#' @param feats input feature
#' @param lab annotation (optional)
#' @param data.age age info

dir.create('./graphAI/input_data')

#' ------------------------
#'  split data and index  |
#' ------------------------
set.seed(123)
rand_indices <- sample(1:nrow(lab),size=nrow(lab))
n1 <- round(nrow(lab)*0.2); n2 <- round(nrow(lab)*0.1)
ps3 = rand_indices[1:n1] #' test
ps2 = rand_indices[(n1+1):(n1+n2)] #' validation
ps1 = rand_indices[(n1+n2+1):length(rand_indices)] #' train

pss <- c(ps1,ps2,ps3)
feat <- feats[pss,]
labs <- new.lab[pss,,drop=FALSE]
dat.age <- data.age[pss,]

#' ----------------------
#'  generate nodes info |
#' ----------------------
#' @export jsons1: nodes
library(rjson); library(future.apply); plan(multiprocess) 

json.1 <- future_lapply(1:nrow(labs),function(i){
    if (i <length(ps1)+1){fool1 <- 'False'; fool2 <- 'False'}
    else if (i>length(ps1)&i<(length(ps1)+length(ps2)+1)){fool1 <- 'False'; fool2 <- 'True'}
    else if (i>(length(ps1)+length(ps2))){fool1 <- 'True'; fool2 <- 'False'}
    if (i==1){
        json1 <- paste0("{'test': ", fool1, ", 'id': ",i-1,", 'feature': ",
                         toJSON(as.numeric(feat[i,])),
                         ", 'val': ", fool2, ", 'label': ",toJSON(as.numeric(labs[i,1])),"}")} else {                                                                                         json1 <- paste0(", {'test': ", fool1, ", 'id': ",i-1,", 'feature': ",
                    toJSON(as.numeric(feat[i,])),
                    ", 'val': ", fool2, ", 'label': ",toJSON(as.numeric(labs[i,1])),"}")
                                                                                             }
    return (json1)
})
jsons1 <- paste0(json.1,collapse='')

#' -----------------------
#'  generate graph info  |
#' -----------------------
#' @export jsons2: links
t1 <- match(adjs[,1],pss); t2 <- match(adjs[,2],pss)
edges <- cbind(t1,t2)

flag1 <- ((length(ps1)+length(ps2)+1):nrow(labs))
flag2 <- setdiff(1:nrow(labs),1:length(ps1))

library(future.apply); plan(multiprocess) 

json.2 <- future_lapply(1:nrow(edges),function(i){
    if ( (edges[i,1] %in% flag1) | (edges[i,2] %in% flag1)){ fool1 <- 'True' }
    else {fool1 <- 'False' }
    if ( (edges[i,1] %in% flag2) | (edges[i,2] %in% flag2)){ fool2 <- 'True' }
    else {fool2 <- 'False' }
    if (i==1){
        if (dat.age[edges[i,1]]<=dat.age[edges[i,2]]){
            json2<-paste0("{'test_removed': ",fool1,", 'target': ",edges[i,2]-1,
                          ", 'train_removed': ",fool2,", 'source': ",edges[i,1]-1,"}")
        } else {
            json2<-paste0("{'test_removed': ",fool1,", 'target': ",edges[i,1]-1,
                          ", 'train_removed': ",fool2,", 'source': ",edges[i,2]-1,"}") } 
    } else {
        if (dat.age[edges[i,1]]<=dat.age[edges[i,2]]){
            json2<-paste0(", {'test_removed': ",fool1,", 'target': ",edges[i,2]-1,
                          ", 'train_removed': ",fool2,", 'source': ",edges[i,1]-1,"}")
        } else {
            json2<-paste0(", {'test_removed': ",fool1,", 'target': ",edges[i,1]-1,
                          ", 'train_removed': ",fool2,", 'source': ",edges[i,2]-1,"}") }
    }
    return (json2) })

jsons2 <- paste0(json.2,collapse='')

#' ----------------------
#'  generate graph info |
#' ----------------------
#' @export G.json
library(jsonlite)
b1 <- structure('True')
b2 <-  paste0("{'name': ",structure('disjoint_union( ,  )}'))

ckd.G <- list(directed= b1,graph=b2,nodes=jsons1,multigraph=b2,links=jsons2)

library(rlang)
ckd.G <- toJSON(ckd.G,auto_unbox=TRUE)

library(d3r)
write(ckd.G, './graphAI/input_data/G.json')

#' -------------------------
#'  generate feature info  |
#' -------------------------
library(RcppCNPy)
rownames(feat) <- 1:nrow(feat)
npySave("./graphAI/input_data/feats.npy",as.matrix(feat))

#' -------------------------
#' generate class-map info |
#' -------------------------
#' @export class-map.json

json.3 <- future_lapply(1:nrow(labs),function(i){
    if (i==1){ json1 <- paste0('{"', i-1, '": ',
                               toJSON(as.numeric(labs[i,1])))
    } else {
        json1 <- paste0(', "', i-1, '": ',
                        toJSON(as.numeric(labs[i,1])))}
})
jsons3 <- paste0(json.3,collapse='')
jsons3 <- toJSON(paste0(jsons3,'}'),auto_unbox=TRUE)

write(jsons3, './graphAI/input_data/class_map.json')

#' ------------------------
#' generate id-map info   |
#' ------------------------
#' @export id-map.json

json.4 <- lapply(1:nrow(labs),function(i){
    if (i==1){json1 <- paste0('{"', i-1, '": ',i-1)} else {
                                                       json1 <- paste0(', "', i-1, '": ',i-1) }})

jsons4 <- paste0(json.4,collapse='')
jsons4 <- toJSON(paste0(jsons4,'}'),auto_unbox=TRUE)

write(jsons4, './graphAI/input_data/id_map.json')

#' ----------------------
#'  generate walks file |
#' ----------------------
#' @export ckd-walks.txt
#' 'ckd-walks.txt' file is generated by walks_utils.py

#' ------------------
#'   run graphAI    |
#' ------------------
#' cd graphAI
#' python -m train.py

#' output: generate log_dir file 
#' output: save model in folder "checkpoints" 
#' output: generate the embedding values (val_value.npy) 

#' ----------------------------------------------
#'  DDRtree using graph-AI learned embedding    |
#' ----------------------------------------------
#' @param embedding
library(DDRTree)

start_time <- Sys.time()
DDRTree_res <- DDRTree(embedding, dimensions = 3, maxIter = 20, sigma = 1e-3, lambda = 1000, ncenter = 1000, param.gamma = 5, tol = 1e-2, verbose = FALSE)
end_time <- Sys.time()
end_time - start_time
