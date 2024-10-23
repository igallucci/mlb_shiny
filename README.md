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
The user interface (ui) was designed to be insightful while also being user friendly. I included various user
inputs to analyze specific teams as well as individual p itchers. A drowdown menu was utilized in the first
visual to select a specific t eam, which g enerated a s catterplot c omparing e ach p itchers o bserved on-base
percentage (obp) to their expected on-base percentage (xobp). Furthermore, users can hover over the points
on the plot to view the pitcher’s name and exact values for both statistics plotted. My second visual is a
bar plot visualizing the average strikeout percentage per team. I included a click event in this plot, which
generates a filtered version o f t he p itchers dataframe with a ll o f t he s tatistics f or t he pitchers from the
selected team. This collection of user inputs allows for individual player and overall team performance to be
analyzed concurrently. In order to make the teams easily differentiable on both visuals, the data on both
plots are encoded according to their club’s colors, courtesy of the teamcolors package.
During data cleaning and preparation, I pulled data from the Baseball Savant website to obtain Statcast
pitcher metrics, and combined it with a player ID map to include the pitchers respective teams. In order to
acquire each teams color scheme for the visuals, I utilized the baseballr package to pull each franchise’s
full name, which corresponded to a specific hex c ode from t eamcolors. To a cquire t he average strikeout
percentage per team, I mutated the pitchers data set to group by each team and assign a mean value to the
k_percent column, creating a column for the second visualization.

## Conclusion
This shiny application serves as an effective tool for analyzing pitcher performance. Through interactive
visualization, the user has the ability to explore the data further and engage with it at a more specific level.
The findings collected from this data can be used to study overall bullpen performance, but the application
could be developed further to gain greater insight into other statistical categories that are critical to pitcher
performance and team success. I welcome any feedback or suggestions on how to build the application further.
