rm(list=ls())

dir_init <- function(path, verbose=FALSE){
    if(substr(path, 1, 2)!='./') stop('path argument must be formatted
        with "./" at beginning')
    contents <- dir(path, recursive=TRUE)
    if(verbose){
        if(length(contents)==0) print(paste('folder ', path, ' created.', sep=""))
        if(length(contents)>0) print(paste('folder ', path, ' wiped of ', length(contents), ' files/folders.', sep=""))
    }
    if(dir.exists(path)) unlink(path, recursive=TRUE)
    dir.create(path)
}

subdir_clone <- function(from, to){
    if(!file.exists(to)) dir.create(to)
    if(from==to) stop('destination must be different from origin')
    files <- list.files(from, full.names=TRUE, recursive=TRUE)
    new_files <- gsub('^\\.', to, files)
    file_begins <- unlist(lapply(gregexpr('/', new_files), max))
    paths <- unique(substr(new_files, 1, file_begins))
    unlink(paths, recursive=TRUE)
    for(i in 1:length(paths)){
        cuts <- gregexpr('/', paths[i])[[1]]
        for(j in 2:length(cuts)){
            proposal <- substr(paths[i], 1, cuts[j])
            if(!file.exists(proposal)) dir.create(proposal)
        }
    }
    file.copy(files, new_files)
}


dir_init('./temp')

files <- list.files('./code', full.names=TRUE)
file.copy(files, './temp')
subdir_clone('./inputs', './temp')
# clone figures in
system("cp -r ./inputs/figures ./temp")

setwd('./temp')
system("pdflatex complete_dissertation.tex")
system("pdflatex complete_dissertation.tex")
system("pdflatex abstract_only.tex")
setwd('..')

dir_init("./output")

file.copy('./temp/complete_dissertation.pdf', './output')
file.copy('./temp/abstract_only.pdf', './output')

unlink('./temp', recursive=TRUE)