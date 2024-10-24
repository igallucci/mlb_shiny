library(tidyverse)
library(shiny)
library(plotly)
library(patchwork)
library(baseballr)
library(teamcolors)

pitchers = read_csv('https://uwmadison.box.com/shared/static/yc6rpnpu13sb8b72vayl87ofuxyk7v4z.csv')
id_teams = read_csv('https://uwmadison.box.com/shared/static/9t5oo6op3j0gqrt9c7yajw2744hlenq2.csv')%>%
  select(LASTNAME, FIRSTNAME, TEAM, MLBID)%>%
  rename(player_id = MLBID)
teams = mlb_teams()%>%filter(sport_name == 'Major League Baseball')%>%
  select(team_full_name, team_abbreviation)%>%
  rename(TEAM = team_abbreviation)

#joining data frames to include pitchers teams
pitchers = left_join(pitchers, id_teams, by = 'player_id')
pitchers = left_join(pitchers, teams, by = 'TEAM')

# manual fix of mismatched abbreviations
pitchers$team_full_name[pitchers$TEAM == 'CHW'] = 'Chicago White Sox'
pitchers$team_full_name[pitchers$TEAM == 'WAS'] = 'Washington Nationals'
pitchers$team_full_name[pitchers$TEAM == 'ARI'] = 'Arizona Diamondbacks'

pitchers = pitchers%>%
  # separating last name and first name into separate columns
  separate(col = `last_name, first_name`, into = c('last_name', 'first_name'), sep = ',', remove = T)%>%
  rename(obp = on_base_percent)%>%
  # removing year because all data comes from 2024 season.
  select(-year, -LASTNAME, -FIRSTNAME)%>%
  drop_na()

# pull teams and xopb
teams = pull(pitchers, team_full_name)%>%
  unique()

# function for first visual: scatterplot
scatterplot = function(df){
  p = ggplot(pitchers, aes(obp, xobp, color = team_full_name, fill = team_full_name))+
    geom_point(data = df %>% filter(selected), aes(text = paste(paste(first_name, last_name), "<br>obp:",obp, "<br>xobp:", xobp)), size = 3, alpha = 1)+
    geom_point(data = df%>% filter (!selected), size = 0.5, alpha = 0.1)+
    scale_fill_teams(guide = FALSE)+
    scale_color_teams(which = 2, guide = FALSE)+
    labs(x = 'On-Base Percentage (obp)', y = 'Expected On-Base Percentage (xobp)')
  ggplotly(p, tooltip = 'text')%>%
    style(hoveron = 'fill')
}

# adding average strikeout percentage to pitchers
pitchers = pitchers%>%
  group_by(TEAM)%>%
  mutate(avg_k_percent = mean(k_percent))%>%
  arrange(avg_k_percent)


# function for second visual: barplot
barplot = function(df, selected_){
  df%>%
    ggplot(aes(reorder(TEAM, avg_k_percent, mean, increasing = T), avg_k_percent, color = team_full_name, fill = team_full_name, alpha = as.numeric(selected_)))+
    geom_bar(stat = 'identity')+
    scale_fill_teams(guide = F)+
    scale_color_teams(which = 2, guide = F)+
    scale_x_discrete(guide = guide_axis(angle = 45))+
    scale_y_continuous(limits = c(0, 35), expand = c(0,0))+
    theme(axis.text = element_text(size = 12))+
    labs(x = 'Team', y = 'Average Strikeout (%)', title = 'Average Strikeout Percentage')
}

# Definition of app
ui <- fluidPage(
  titlePanel("MLB Pitcher Comparative Analysis"),
  selectInput('teams', 'Team', teams),
  plotlyOutput('obp_comparison'),
  plotOutput('bar_plot', click = 'plot_click'),
  dataTableOutput('table')
)

# Define the server
server <- function(input, output) {
  pitcher_subset = reactive({
    pitchers%>%
      mutate(selected = 
               team_full_name %in% input$teams
      )
  })
  
  selected = reactiveVal(rep(1, nrow(pitchers)))
  observeEvent(
    input$plot_click,{
      click_x = round(input$plot_click$x)
      selected_team = unique(pitchers$TEAM)[click_x]
      
      selected(as.numeric(pitchers$TEAM == selected_team))
    })
  
  
  output$obp_comparison = renderPlotly({
    scatterplot(pitcher_subset())
  })
  
  output$bar_plot = renderPlot({barplot(pitchers, selected())})
  output$table = renderDataTable({
    filtered_data = pitchers[selected() == 1, ]
  })
}

# Run the application 
shinyApp(ui, server)
