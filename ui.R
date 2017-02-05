library(leaflet)

navbarPage("US Death Records", id="nav",

           tabPanel("Map Explorer",
                    div(class="outer",
                        tags$head(
                          includeCSS("styles.css")
                        ),

                        leafletOutput("map", width="100%", height="100%"),
                        tags$div(id="cite",'Shiny App Project By Vrishali Giri & Tess Thomas.'
                        )
                    )
           ),
           
           tabPanel("Data Explorer",
                    sidebarLayout(
                      sidebarPanel(
                        selectInput("diseaseInput",
                                    "select Disease",
                                    choices = disease, selected = "Stroke"),
                        sliderInput("AgeInput","select age", min=0, max = 110,
                                    value = c(10,110)),
                        selectInput("sexInput", "Select Gender", 
                                    choices = sex),
                        selectInput("statesInput", 
                                    "Select State", 
                                    choices = states),
                        radioButtons("renderInput","Render Table", 
                                     c("Yes","No"), selected = "No")
                      ),
                      mainPanel(
                        plotOutput("myhist"),
                        br(), br(),
                        conditionalPanel("input.renderInput == 'Yes'",
                        tableOutput("datatable"))
                      )
                    )
           ),
           tabPanel("Disease Summary",
                    sidebarLayout(
                      sidebarPanel(
                        selectInput("diseaseInput2",
                                    "Cause of Death",
                                    choices = disease, selected = "Stroke")
                      ),
                      mainPanel(
                        plotOutput("myDiseaseSummary")
                       
                      )
                    )
           ),

           tabPanel("Data Grid",
                    sidebarLayout(
                      sidebarPanel(
                        checkboxGroupInput('show_vars', 
                                           'Columns to show:', 
                                           names(allzips),
                                           selected = names(allzips))
                      ),
                      mainPanel(
                        tabsetPanel(
                          tabPanel('Data Browser',
                                   dataTableOutput("mytable1")))

                      )
                    )
           )
)