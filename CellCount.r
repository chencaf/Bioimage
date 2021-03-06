## Copyright Tong Wei, July 2012
## Graphical application of R/biocondcutor "EBImage"

## Automated nuclei counting with adjustable parameters: thresh(w, h, offset), 
## makeBrush(size), small spots with less pixels (< 100 herein)


library(EBImage)

# read in images
setwd("d:/working/")
files <- grep(".tif$", dir(), value = T)
pic <- readImage(files)
pic.blue <- channel(pic, mode = "blue")  # extract the corresponding channel

# filter 1: remove background noise
tmp <- thresh(pic.blue, w = 100, h = 100, offset = 0.2)  
# filter 2: modify the morphological shape
kern <- makeBrush(5, shape = "disc", step = F)
tmp <- dilate(erode(tmp, kern), kern)
pic.lab <- bwlabel(tmp)
# filter 3: remove morphological shape with less pixels
tmp2 <- imageData(pic.lab)
tmp3 <- tmp2[tmp2 != 0]
tmp3 <- table(tmp3)
mt <- names(tmp3)[tmp3 < 100]
mt <- as.numeric(mt)
for (i in mt) {
  tmp2[tmp2 == i] <- 0
}
imageData(pic.lab) <- tmp2

pic.lab <- fillHull(pic.lab)
nuclei.count <- max(pic.lab)
cat("The number of nuclei is ", nuclei.count, ".\n", sep = "")

# output the labelled image
pic.out <- paintObjects(pic.lab, pic, col = c('yellow', NA))
xy <- hullFeatures(pic.lab)[, c('g.x', 'g.y')]
font <- drawfont(weight = 600, size = 16)
pic.out <- drawtext(pic.out, xy = xy, labels = as.character(1:nrow(xy)), 
                    font = font, col = "white")
files.out <- paste("out", files, sep = "")
writeImage(pic.out, files.out)