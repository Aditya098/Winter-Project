library(shiny)
library(ggplot2)
library(twitteR)
library(ggmap)
library(maps)
library(ggplot2)
library(NbClust)
library(httr)
library(devtools)
library(RColorBrewer) 

shinyServer(function(input, output, session) {
  
    output$plot1 <- renderPlot({
    
      options(httr_oauth_cache=T)
      api_key <- "xxxxxxxxxxxxxxxxx"
      api_secret <- "kdCmc7PD5Srxxxxxxxxxxxxxx"
      token <- "4717263320-k3Abxxxxxxxxxxxxxxxxxxxx"
      token_secret <- "Zr67eFdorrDxxxxxxxxxxxxxxxxx"
      
    # Create Twitter Connection
    options(httr_oauth_cache=T)
    setup_twitter_oauth(api_key, api_secret, token, token_secret)
    
    user <- try(getUser(input$usernam),silent=TRUE) 
    followers <- user$getFollowers(input$ab)  #limiting followers
    followers <- twListToDF(followers)    #converting to dataframe
    followers$location[followers$location==""] <- NA    #assigning NA (not applicable)to 
                                            #followers whose location is not specified 
    
    followers <- followers[sample(1:nrow(followers), size =input$ab, replace=TRUE),] 
                                                   #size must be input$ab 
    
    loc1<- !is.na(followers$location) 
    loc<-followers$location[loc1]   
    coord <- geocode(loc)          # geocoding the followers locations
    
  # coord <- read.table("coord.txt")
    
    nb <- NbClust(coord, distance = "euclidean", min.nc = 2,
                  max.nc = 15, method = "centroid", index ="all")  
    
    nClust<-length(unique(nb$Best.partition))
    kmeans.df <- data.frame(lat = coord$lat,
                            lon = coord$lon)
    kmeans.df <- na.omit(kmeans.df)     #omiting terms with NA 
    
    
    fit <- kmeans(kmeans.df, centers = nClust, nstart = 20)
    
    kmeans.df$cluster = fit$cluster #adding cluster column to data frame
    
    colfunc<-colorRampPalette(c("red","yellow","springgreen","royalblue"))
    cols <- colfunc(nClust)  #assigning colors to points with same cluster number
    for(i in 1:nClust){
      kmeans.df$color[kmeans.df$cluster == i] <- cols[i]
    }
    
    kmeans.df$Cluster <- as.factor(kmeans.df$cluster)
    
    map.dat <- map_data("world")
    
    g <- ggplot() +                       #plotting the geopoints with clusters 
      geom_polygon(aes(long,lat, group=group), fill="grey85", data=map.dat) +
      geom_jitter(aes(x = lon, y = lat, fill=Cluster,
                      colour=Cluster), alpha=1, size=1.4,  data = kmeans.df) + 
      guides(fill = guide_legend( override.aes = list(alpha = 1))) +
      theme_minimal() +
      theme(text = element_text(size=15),
            legend.position="top")
    
    g <- g +                           # for density based clustering
      stat_density_2d(
        aes(x = lon, y = lat,fill=as.factor(cluster), colour=as.factor(cluster)), 
        bins = 10, alpha=.2,
        size=0, data = kmeans.df, geom = "polygon") 
    
    g
    
  })
})
