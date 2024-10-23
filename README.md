# Comparative Analysis of MLB Pitchers
Final shiny application can be found [here](https://igallucci.shinyapps.io/HW2_App/)

## Introduction
In this project, I developed a set of interactive visualizations to compare various statistics from MLB pitchers
during the 2024 regular season. By utlizing data collected by MLB Statcast and stored on its companion
website, Baseball Savant, as well as one outside source to include the players’ teams, this app allows users to
analyze individual pitcher and team performance to gain insight into which players and teams have the best
performing bullpen (group of pitchers on a given team) from the most recent season.

## Notable Findings
Since its introduction to the league in 2015, Statcast has changed the way fans, players, coaches, and front
offices alike watch America’s pa sstime. Pitchers in particular are scouted and judged based on their ability to
prevent batters from getting on base and scoring runs against their own team. The most interesting findings I
discovered during my analysis was the variety of performance in some of the league’s top teams. For instance,
the New York Mets (NYM), who reached the National League Championship Series this season, are among
the bottom tier in terms of bullpen performance. It seems that factors outside of their pitching attributed to
their success, but further analysis would be required to determine this.

## User Interface Creation
During data cleaning and preparation, I pulled data from the Baseball Savant website to obtain Statcast
pitcher metrics, and combined it with a player ID map to include the pitchers respective teams. In order to
acquire each teams color scheme for the visuals, I utilized the baseballr package to pull each franchise’s
full name, which corresponded to a specific hex c ode from t eamcolors. To a cquire t he average strikeout
percentage per team, I mutated the pitchers data set to group by each team and assign a mean value to the
k_percent column, creating a column for the second visualization.
```{r}
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
```

The user interface (ui) was designed to be insightful while also being user friendly. I included various user
inputs to analyze specific teams as well as individual pitchers. A drowdown menu was utilized in the first
visual to select a specific team, which generated a scatterplot comparing each pitchers observed on-base
percentage (obp) to their expected on-base percentage (xobp). Furthermore, users can hover over the points
on the plot to view the pitcher’s name and exact values for both statistics plotted. 
```{r}
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
```

My second visual is a bar plot visualizing the average strikeout percentage per team. I included a click event in this plot, which
generates a filtered version o f t he p itchers dataframe with all of the statistics for the pitchers from the
selected team. This collection of user inputs allows for individual player and overall team performance to be
analyzed concurrently. In order to make the teams easily differentiable on both visuals, the data on both
plots are encoded according to their club’s colors, courtesy of the teamcolors package.
```{r}
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
```

## Conclusion
This shiny application serves as an effective tool for analyzing pitcher performance. Through interactive
visualization, the user has the ability to explore the data further and engage with it at a more specific level.
The findings collected from this data can be used to study overall bullpen performance, but the application
could be developed further to gain greater insight into other statistical categories that are critical to pitcher
performance and team success. I welcome any feedback or suggestions on how to build the application further.
