library(leaflet)
library(raster)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(rMaps)
library(ggplot2)

# Leaflet bindings are a bit slow; for now we'll just sample to compensate

zipdata <- allzips#[sample.int(nrow(allzips), 10000),]

function(input, output, session) {
  
  ## Interactive Map ###########################################

  output$map <- renderLeaflet({
    
     leaflet() %>%
       addTiles(
         urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
         attribution = NULL
       #addMarkers(data = zipdata) 
         ) %>%
      #addPolygons(data=zipdata, weight = 2, fillColor = "yellow") %>%
       setView(lng = -93.85, lat = 37.45, zoom = 4)
  })
  
  # This observer is responsible for maintaining the circles
   observe({
    leafletProxy("map", data = zipdata) %>%
      clearShapes() %>%
      addCircles(~longitude, ~latitude, radius=500, layerId=~zipcode,
                 stroke=FALSE, fillOpacity=0.9, fillColor= "Red")
  })
  
#  Show a popup at the given location
  showZipcodePopup <- function(zipcode, lat, lng) {
    selectedZip <- allzips[allzips$zipcode == zipcode,]
    content <- as.character(tagList(
      tags$strong(HTML(sprintf("%s, %s, %s",
                               selectedZip$City[1], selectedZip$LocationDesc[1], selectedZip$zipcode[1]
      ))
    ), tags$br(),
      sprintf("Average Age Group: %s years", round(mean(selectedZip$Age),2)), tags$br(),
      sprintf("Death Rate: %s%%", round((table(selectedZip$zipcode) / total) * 100, 2)), tags$br()
    ))
    leafletProxy("map") %>% addPopups(lng, lat, content, layerId = zipcode)
  }
  
  # When map is clicked, show a popup with city info
  observe({
    leafletProxy("map") %>% clearPopups()
    event <- input$map_shape_click
    if (is.null(event))
      return()

    isolate({
      showZipcodePopup(event$id, event$lat, event$lng)
    })
  })
  
  ## Data Explorer ###########################################
  
  output$myhist <- renderPlot ({

    filtered <-zipdata %>% filter(
      is.null(input$statesInput) | LocationDesc == input$statesInput,
      Sex == input$sexInput ,
      Disease == input$diseaseInput,
      Age >= input$AgeInput[1],Age <= input$AgeInput[2]
    )

    ggplot(filtered, aes(x=Age)) + geom_bar(fill="#FF9999", colour="black")
  })
  
  output$datatable <- renderTable({
    filtered <-
      zipdata %>%
      filter(Age >= input$AgeInput[1],
             Age <= input$AgeInput[2],
             is.null(input$statesInput) | LocationDesc %in% input$statesInput,
             is.null(input$sexInput) | Sex %in% input$sexInput,
             is.null(input$diseaseInput) | Disease %in% input$diseaseInput
      )
    filtered
  })
  
  ######### Disease Summary #######################
  output$myDiseaseSummary <- renderPlot ({
    filtered2 <- zipdata %>% filter(
      Disease == input$diseaseInput2
    )
    ggplot(filtered2, aes(Age)) + geom_density(aes(fill=factor(Sex)), size=1, alpha=.4)
  })

  ######### Data Grid #######################
  output$mytable1 = renderDataTable({
    library(ggplot2)
    allzips[, input$show_vars, drop = FALSE]
  })
}