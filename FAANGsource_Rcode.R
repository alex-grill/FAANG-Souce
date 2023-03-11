
# Link to live Shiny Application:
  # https://grilla.shinyapps.io/FAANG_Source/

# Load required libraries
library(shiny)
library(shinydashboard)
library(ggplot2)
library(shinyWidgets)
library(DBI)
library(odbc)
library(DT)

# Read database credentials
source("./credentials_G25.R")

# UI CODE
ui <- dashboardPage(skin = "green",
  dashboardHeader(title = "FAANG Source"),
  # Sidebar content
  dashboardSidebar(
  # Sidebar menus
    sidebarMenu(
      menuItem("Home", tabName = "Homepage", icon = icon("house")),
      menuItem("Create New User", tabName = "UserInfoEntry", icon = icon("user")),
      menuItem("Data Entry", tabName = "UserInputEntry", icon = icon("keyboard")),
      menuItem("Search Database", tabName = "DBsearch", icon = icon("database")),
      menuItem("Salary Analytics", tabName = "SalaryAnalytics", icon = icon("chart-pie")),
      menuItem("User Settings", tabName = "UserSettings", icon = icon("gears")))
  ),
  dashboardBody(
    tabItems(
      # Contents for Homepage
      tabItem(tabName = "Homepage",
              h1("Welcome to FAANG Source!"),
              h4(strong("The #1 resource for user-submitted Big Tech salary information.")),
              br(),
              h2(strong("Tab Glossary:")),
              h3("Create New User:"),
              h5("Create a User ID by submitting your first name, last name, email address, gender, and age."),
              h3("Data Entry:"),
              h5("Users with FAANG work experience can enter their salary information from current or previous roles
                along with characteristics such as: highest level of education achieved, years of experience, and office location."),
              h3("Search Database:"),
              h5("Utilize all real-time data collected to find salaries specific to your individual characteristics, 
                 providing a key benchmarking platform for future salary negotiations."),
              h3("Salary Analytics:"),
              h5("Find valuable salary insights for various FAANG companies, positions, 
                 office locations, and more."),
              h3("User Settings:"),
              h5("View a table of all your submitted data entries, delete and edit previously submitted entries, 
                 edit any wrongly inputted user information, as well as find a forgotten User ID."),
      ),
      # Contents for Create New User Tab
      tabItem(tabName = "UserInfoEntry",
              h2("Create New User:"),
              h4(strong("Please fill out the following information, then click 'Create User' to recieve your User ID.")),
              h3(),
              h6(strong("* = Required")),
              textInput("fname", label = h4("*First Name:"), placeholder = "Type your full first name"),
              textInput("lname", label = h4("*Last Name:"), placeholder = "Type your full last name"),
              textInput("email", label = h4("*Email Address:"), placeholder = "Type your email address"),
              pickerInput("gender", label = h4("Gender:"), 
                          choices = list(" " = " 'Unidentified' ", "Male" = " 'Male' ", "Female" = " 'Female' "), selected = 1),
              sliderInput("age", label = h4("*Age:"), min = 18, max = 50, value = 20),
              br(),
              actionBttn("Info", label = "Create User", style = "gradient", color = "success"),
              h3(),
              h4(strong("Your User ID is:")),
              textOutput("userIDentry", container = tags$h3)
      ),
      # Contents for Data Entry Tab
      tabItem(tabName = "UserInputEntry",
              h2("Enter Your FAANG Job Data:"),
              h4(strong("Please fill out the following information, then click 'Submit' to add an entry into the database.")),
              h5("NOTE: This tab is only for users previously or currently employeed by a FAANG company."),
              h3(),
              h6(strong("* = Required")),
              textInput("inputUID", label = h4("*User ID:"), placeholder = "Type your User ID"),
              radioGroupButtons("companywf", label = h4("*FAANG Company:"),
                choices = list("Facebook" = " 'Facebook' " , "Apple" = " 'Apple' ", "Amazon" = " 'Amazon' ",
                               "Netflix" = " 'Netflix' ", "Google" = " 'Google' "),
                checkIcon = list(yes = tags$i(class = "fa fa-check-square", style = "color: green"),
                                 no = tags$i(class = "fa fa-square-o", style = "color: green")), selected = 0),
              pickerInput("postitle", label = h4("*Position:"),
                choices = list("Data Analyst 1" = " 'Data Analyst 1' ", "Data Analyst 2" = " 'Data Analyst 2' ",
                               "Data Analyst 3" = " 'Data Analyst 3' ", "Data Scientist 1" = " 'Data Scientist 1' ",
                               "Data Scientist 2" = " 'Data Scientist 2' ", "Data Scientist 3" = " 'Data Scientist 3' ",
                               "Data Engineer 1" = " 'Data Engineer 1' ", "Data Engineer 2" = " 'Data Engineer 2' ",
                               "Data Engineer 3" = " 'Data Engineer 3' ", "Software Engineer 1" = " 'Software Engineer 1' ",
                               "Software Engineer 2" = " 'Software Engineer 2' ", "Software Engineer 3" = " 'Software Engineer 3' ",
                               "Network Engineer 1" = " 'Network Engineer 1' ", "Network Engineer 2" = " 'Network Engineer 2' ", 
                               "Network Engineer 3" = " 'Network Engineer 3' ", "Financial Analyst" = " 'Financial Analyst; ",
                               "Senior Financial Analyst" = " 'Senior Financial Analyst' ", "Finance Manager" = " 'Finance Manager' ",
                               "Marketing Associate" = " 'Marketing Associate' ",
                               "Senior Marketing Associate" = " 'Senior Marketing Associate' ",
                               "Marketing Manager" = " 'Marketing Manager' ", "Account Manager" = " 'Account Manager' ",
                               "Program Manager" = " 'Program Manager' ", "Project Manager" = " 'Project Manager' ",
                               "Technical Business Manager" = " 'Technical Business Manager' ")),
              pickerInput("leveledu", label = h4("*Highest Level of Education Achieved:"),
                choices = list("High School Degree" = " 'High School Degree' " ,
                               "Undergraduate Degree" = " 'Undergraduate Degree' ",
                               "Postgraduate Degree" = " 'Postgraduate Degree' ")),              
              pickerInput("yearsexp", label = h4("*Years of Experience:"), 
                choices = list("0-2 Years" = " '0-2 Years' " , "3-5 Years" = " '3-5 Years' ", "6-10 Years" = " '6-10 Years' ")),
              pickerInput("officeloc", label = h4("*Office You Worked At:"),
                choices = list("Austin, TX" = " 'Austin, TX' " , "New York, NY" = " 'New York, NY' ", 
                               "San Francisco, CA" = " 'San Francisco, CA' ")),
              textInput("salentry", label = h4("*Salary:"), placeholder = "No commas, rounded to the nearest 100"),
              actionBttn("Input", label = "Submit", style = "gradient", color = "success"),
              h3(),
              textOutput("EntrySuccess", container = tags$h4)
      ),
      # Contents for Search Database Tab
      tabItem(tabName = "DBsearch",
              h2("Search Database:"),
              h4(strong("Find salary information from employees across Big Tech based on the following parameters.")),
              h5("NOTE: Selecting no parameters will display the entire database."),
              h3(),
              bootstrapPage(
                div(style="display:inline-block", pickerInput("dbqco", label = h4("FAANG Company:"), 
                    choices = list(" " = " '%%' ", "Facebook" = " 'Facebook' " , "Apple" = " 'Apple' ", "Amazon" = " 'Amazon' ",
                                   "Netflix" = " 'Netflix' ", "Google" = " 'Google' "))
                    ),
                div(style="display:inline-block", pickerInput("dbqjob", label = h4("Position:"), 
                    choices = list(" " = " '%%' ", "Data Analyst 1" = " 'Data Analyst 1' ", "Data Analyst 2" = " 'Data Analyst 2' ",
                                   "Data Analyst 3" = " 'Data Analyst 3' ", "Data Scientist 1" = " 'Data Scientist 1' ",
                                   "Data Scientist 2" = " 'Data Scientist 2' ", "Data Scientist 3" = " 'Data Scientist 3' ",
                                   "Data Engineer 1" = " 'Data Engineer 1' ", "Data Engineer 2" = " 'Data Engineer 2' ",
                                   "Data Engineer 3" = " 'Data Engineer 3' ", "Software Engineer 1" = " 'Software Engineer 1' ",
                                   "Software Engineer 2" = " 'Software Engineer 2' ", "Software Engineer 3" = " 'Software Engineer 3' ",
                                   "Network Engineer 1" = " 'Network Engineer 1' ", "Network Engineer 2" = " 'Network Engineer 2' ", 
                                   "Network Engineer 3" = " 'Network Engineer 3' ", "Financial Analyst" = " 'Financial Analyst' ",
                                   "Senior Financial Analyst" = " 'Senior Financial Analyst' ", "Finance Manager" = " 'Finance Manager' ",
                                   "Marketing Associate" = " 'Marketing Associate' ",
                                   "Senior Marketing Associate" = " 'Senior Marketing Associate' ",
                                   "Marketing Manager" = " 'Marketing Manager' ", "Account Manager" = " 'Account Manager' ",
                                   "Program Manager" = " 'Program Manager' ", "Project Manager" = " 'Project Manager' ",
                                   "Technical Business Manager" = " 'Technical Business Manager' "))),
              ),
              p(),
              bootstrapPage(
                div(style="display:inline-block", pickerInput("dbqedu", label = h4("Education Level:"), 
                    choices = list(" " = " '%%' ", "High School Degree" = " 'High School Degree' ",
                                   "Undergraduate Degree" = " 'Undergraduate Degree' ",
                                   "Postgraduate Degree" = " 'Postgraduate Degree' "))
                    ),
                div(style="display:inline-block", pickerInput("dbqexp", label = h4("Years of Experience:"), 
                    choices = list(" " = " '%%' ", "0-2 Years" = " '0-2 Years' " ,
                                   "3-5 Years" = " '3-5 Years' ", "6-10 Years" = " '6-10 Years' "))
                    ),
                div(style="display:inline-block", pickerInput("dbqoffice", label = h4("Office Location:"),
                    choices = list(" " = " '%%' ", "Austin, TX" = " 'Austin, TX' " , "New York, NY" = " 'New York, NY' ", 
                                   "San Francisco, CA" = " 'San Francisco, CA' "))),
              ),
              p(),
              actionBttn("DBSearch", label = "Search", style = "gradient", color = "success"),
              hr(),
              DT::dataTableOutput("mytableDBQ")
      ),
      # Contents for Salary Analytics Tab
      tabItem(tabName = "SalaryAnalytics",
              h2("Salary Analytics:"),
              h4(strong(("Get a better understanding of salary averages amongst various demographics."))),
              h3(),
              pickerInput("AVGchoice", label = h4("Average Salary Based On:"),
                choices = list("FAANG Company" = 
                                  "SELECT c.company_name AS 'FAANG Company', 
                                          AVG(uinp.salary) AS 'Average Salary'
                                   FROM UserInfo as uinf
                                   JOIN UserInput as uinp
                                   ON uinf.user_id = uinp.user_id
                                   JOIN Job as j
                                   ON uinp.job_id = j.job_id
                                   JOIN Company as c
                                   ON j.company_id = c.company_id
                                   GROUP BY c.company_name
                                   ORDER BY AVG(uinp.salary) DESC;",
                               "Position" = 
                                  "SELECT j.job_title AS 'Position', 
                                          AVG(uinp.salary) AS 'Average Salary'
                                   FROM UserInfo as uinf
                                   JOIN UserInput as uinp
                                   ON uinf.user_id = uinp.user_id
                                   JOIN Job as j
                                   ON uinp.job_id = j.job_id
                                   JOIN Company as c
                                   ON j.company_id = c.company_id
                                   GROUP BY j.job_title
                                   ORDER BY AVG(uinp.salary) DESC;",
                               "Gender" =
                                 "SELECT uinf.gender AS 'Gender', 
                                          AVG(uinp.salary) AS 'Average Salary'
                                   FROM UserInfo as uinf
                                   JOIN UserInput as uinp
                                   ON uinf.user_id = uinp.user_id
                                   JOIN Job as j
                                   ON uinp.job_id = j.job_id
                                   JOIN Company as c
                                   ON j.company_id = c.company_id
                                   GROUP BY uinf.gender
                                   ORDER BY AVG(uinp.salary) DESC;",
                               "Age Range" =
                                 "SELECT CASE
                                     WHEN uinf.age < 27 THEN '20-26'
                                     WHEN uinf.age BETWEEN 27 AND 33 THEN '27-33'
                                     WHEN uinf.age BETWEEN 34 AND 40 THEN '34-40'
                                     END AS 'Age Range', 
                                     AVG(uinp.salary) as 'Average Salary'
                                  FROM UserInfo as uinf
                                  JOIN UserInput as uinp
                                  ON uinf.user_id = uinp.user_id
                                  JOIN Job as j
                                  ON uinp.job_id = j.job_id
                                  JOIN Company as c
                                  ON j.company_id = c.company_id
                                  GROUP BY CASE
                                     WHEN uinf.age < 27 THEN '20-26'
                                     WHEN uinf.age BETWEEN 27 AND 33 THEN '27-33'
                                     WHEN uinf.age BETWEEN 34 AND 40 THEN '34-40'
                                     END
                                  ORDER BY AVG(uinp.salary) DESC;",
                               "Education Level" = 
                                  "SELECT uinp.education_level AS 'Education Level', 
                                          AVG(uinp.salary) AS 'Average Salary'
                                   FROM UserInfo as uinf
                                   JOIN UserInput as uinp
                                   ON uinf.user_id = uinp.user_id
                                   JOIN Job as j
                                   ON uinp.job_id = j.job_id
                                   JOIN Company as c
                                   ON j.company_id = c.company_id
                                   GROUP BY uinp.education_level
                                   ORDER BY AVG(uinp.salary) DESC;",
                               "Years of Experience" =
                                  "SELECT uinp.years_of_exp AS 'Years of Experience',
                                          AVG(uinp.salary) AS 'Average Salary'
                                   FROM UserInfo as uinf
                                   JOIN UserInput as uinp
                                   ON uinf.user_id = uinp.user_id
                                   JOIN Job as j
                                   ON uinp.job_id = j.job_id
                                   JOIN Company as c
                                   ON j.company_id = c.company_id
                                   GROUP BY uinp.years_of_exp
                                   ORDER BY AVG(uinp.salary) DESC;",
                               "Office Location" =
                                  "SELECT uinp.office_location AS 'Office Location', 
                                            AVG(uinp.salary) AS 'Average Salary'
                                   FROM UserInfo as uinf
                                   JOIN UserInput as uinp
                                   ON uinf.user_id = uinp.user_id
                                   JOIN Job as j
                                   ON uinp.job_id = j.job_id
                                   JOIN Company as c
                                   ON j.company_id = c.company_id
                                   GROUP BY uinp.office_location
                                   ORDER BY AVG(uinp.salary) DESC;")
              ),
              p(),
              actionBttn("AVGquery", label = "Display", style = "gradient", color = "success"),
              hr(),
              plotOutput("AVGplot"),
              br(),
      ),
      # Contents for User Settings Tab
      tabItem(tabName = "UserSettings",
              h2("User Settings:"),
              h3(),
              navbarPage(title = icon("gears"), windowTitle = icon("gears"),
                  tabPanel(strong("My Entries"),
                           h4(strong(("Type your User ID, then click 'Search' to view a table of your submitted entries."))),
                           h3(),
                           textInput("EntryQuery", label = h4("User ID:"), 
                                     placeholder = "Type your User ID"),
                           h2(),
                           actionBttn("UserEntries", label = "Search", style = "gradient", color = "success"),
                           hr(),
                           DT::dataTableOutput("myEntries")
                  ),
                  tabPanel(strong("Edit Entry"),
                           h4(strong("Type your User ID and Entry Number, then click 'Edit' to submit specific updates. 
                                     You can confirm your updates in the 'My Entries' section.")),
                           h5("NOTE: Please make one edit at a time. If you need to edit your FAANG Company or Position information,
                              please delete your entry and resubmit using the 'Data Entry' tab."),
                           h3(),
                           bootstrapPage(
                             div(style="display:inline-block", 
                                 textInput("editUID", label = h4("User ID:"), 
                                           placeholder = "Type your User ID")),
                             div(style="display:inline-block",
                                 textInput("editEntryID", label = h4("Entry Number:"), 
                                           placeholder = "Type the Entry Number you want to update")),
                                        ),
                             p(),
                             box(
                               title = " ", status = "success",
                               solidHeader = TRUE,collapsible = TRUE,
                               prettyRadioButtons("EntryEditSelect", label = h4("Edit Education, Experience, or Office:"),
                                                  choices = list("Highest Level of Education Achieved" = "education_level",
                                                                 "Years of Experience" = "years_of_exp",
                                                                 "Office You Worked At" = "office_location"),
                                                  status = "success", outline = TRUE),
                               pickerInput("EEOedit", 
                                           choices = list(
                                                       "Education Level" = list( 
                                                            "High School Degree" = " 'High School Degree' ",
                                                            "Undergraduate Degree" = " 'Undergraduate Degree' ",
                                                            "Postgraduate Degree" = " 'Postgraduate Degree' "),
                                                        "Years of Experience" = list(
                                                            "0-2 Years" = " '0-2 Years' " , 
                                                            "3-5 Years" = " '3-5 Years' ",
                                                            "6-10 Years" = " '6-10 Years' "),
                                                       "Office Location" = list(
                                                            "Austin, TX" = " 'Austin, TX' " ,
                                                            "New York, NY" = " 'New York, NY' ", 
                                                            "San Francisco, CA" = " 'San Francisco, CA' "))
                               ),
                               actionBttn("EntryEdit1", label = "Edit", style = "gradient", color = "success"),
                               h3(),
                               textOutput("EditSuccess1", container = tags$h4)
                               ),
                             box(
                               title = " ", status = "success",
                               solidHeader = TRUE, collapsible = TRUE,
                               textInput("SALedit", label = h4("Edit Salary:"), placeholder = "No commas, rounded to the nearest 100"),
                               actionBttn("EntryEdit2", label = "Edit", style = "gradient", color = "success"),
                               h3(),
                               textOutput("EditSuccess2", container = tags$h4)
                             ),
                  ),
                  tabPanel(strong("Delete Entry"),
                           h4(strong("Type your User ID and Entry Number, then click 'Delete' to remove your entry from the database.")),
                           h5("NOTE: Clicking 'Delete' will remove your entry from the database forever."),
                           h3(),
                           bootstrapPage(
                             div(style="display:inline-block", 
                                 textInput("deleteUID", label = h4("User ID:"), 
                                           placeholder = "Type your User ID")),
                             div(style="display:inline-block",
                                 textInput("deleteEntryID", label = h4("Entry Number:"), 
                                           placeholder = "Type the Entry Number you want removed"))),
                           p(),
                           actionBttn("EntryDelete", label = "Delete", style = "gradient", color = "success"),
                           h3(),
                           textOutput("DeleteSuccess", container = tags$h4)
                  ),
                  tabPanel(strong("Edit User Info"),
                           h4(strong("Type your User ID, then click 'Edit' to submit specific updates to your user information. 
                                     Click 'Find User' to confirm your updates.")),
                           h5("NOTE: Please make one edit at a time."),
                           h3(),
                           textInput("editUserInfo", label = h4("User ID:"), 
                                     placeholder = "Type your User ID"),
                           h2(),
                           box(
                             title = " ", status = "success",
                             solidHeader = TRUE,collapsible = TRUE,
                             prettyRadioButtons("UserEditSelect", label = h4("Edit Personal Information:"),
                                                choices = list("First Name" = "first_name",
                                                               "Last Name" = "last_name",
                                                               "Email Address" = "email_address"),
                                                status = "success", outline = TRUE),
                             textInput("UserTextEdit", label = NULL, placeholder = "Type the edit you want to make here"),
                             actionBttn("UserEdit1", label = "Edit", style = "gradient", color = "success"),
                             h3(),
                             textOutput("UserEditSuccess1", container = tags$h4)
                           ),
                           box(
                             title = " ", status = "success",
                             solidHeader = TRUE, collapsible = TRUE,
                             pickerInput("GenderEdit", label = h4("Gender:"), choices = 
                                           list(" " = " 'Unidentified' ", "Male" = " 'Male' ", "Female" = " 'Female' "), selected = 1),
                             actionBttn("UserEdit2", label = "Edit", style = "gradient", color = "success"),
                             h3(),
                             textOutput("UserEditSuccess2", container = tags$h4),
                             h3(),
                             sliderInput("AgeEdit", label = h4("Age:"), min = 18, max = 50, value = 20),
                             actionBttn("UserEdit3", label = "Edit", style = "gradient", color = "success"),
                             h3(),
                             textOutput("UserEditSuccess3", container = tags$h4)
                           ),
                           h4(strong("Check Your Edits:")),
                           actionBttn("UserInfoCheck", label = "Find User", style = "gradient", color = "success"),
                           hr(),
                           DT::dataTableOutput("myUserInfo")
                  ),
                  tabPanel(strong("Forgot User ID"),
                           h4(strong(("Type your First and Last name, then click 'Find' to access your User ID."))),
                           h3(),
                           bootstrapPage(
                             div(style="display:inline-block", 
                                 textInput("forgot1", label = h4("First Name:"), 
                                           placeholder = "Type the first name attached to your account")),
                             div(style="display:inline-block",
                                 textInput("forgot2", label = h4("Last Name:"), 
                                           placeholder = "Type the last name attached to your account"))),
                           p(),
                           actionBttn("FindUser", label = "Find", style = "gradient", color = "success"),
                           h3(),
                           h4(strong("Your User ID is:")),
                           textOutput("userIDforgot", container = tags$h3)
                  )
                )
              )
    )
  )
)

# SERVER CODE
server <- function(input, output) {
  
  # Create New User Tab Query
  observeEvent(input$Info, {
    # Open DB connection
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
    
    # browser()
    query1 <- paste("INSERT INTO UserInfo (first_name, last_name,
                                       email_address, gender, age) 
                     VALUES ('", input$fname,"', '", input$lname,"' ,
                             '", input$email,"', ", input$gender,",
                             '", input$age,"');", sep = "")
                    
    query2 <- paste("SELECT user_id
                     FROM UserInfo
                     WHERE first_name = '" ,input$fname, "' 
                     AND last_name = '" ,input$lname, "';", sep = "")
                    
    data1 <- dbGetQuery(db,query1)
    
    data2 <- dbGetQuery(db,query2)
    
    output$userIDentry <- renderText({ data2[1,1] })
    
    })
  
  # Data Entry Tab Query
  observeEvent(input$Input, {
    # Open DB connection
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
    
    # browser()
    query3 <- paste("INSERT INTO UserInput (user_id, education_level, 
                                years_of_exp, office_location, salary) 
                     VALUES ('", input$inputUID,"', ", input$leveledu,",
                             ", input$yearsexp,", ", input$officeloc,",
                             '", input$salentry,"');", sep = "")
    
    query4 <- paste("UPDATE UserInput
                     SET job_id = (SELECT j.job_id
                          			   FROM Job as j
                          			   JOIN Company as c
                          			   ON j.company_id = c.company_id
                          			   WHERE c.company_name = ", input$companywf," 
                          			   AND j.job_title = ", input$postitle,")
                     WHERE user_id = ", input$inputUID," 
                     AND salary = ", input$salentry,";", sep = "")
    
    data3 <- dbGetQuery(db,query3)
    
    data4 <- dbGetQuery(db,query4)
    
    output$EntrySuccess <- renderText({"Your entry has been submitted."})
    
  })
  
  # Search Database Tab Query
  observeEvent(input$DBSearch, {
    # open DB connection
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
    
    # browser()
    query <- paste("SELECT c.company_name AS 'FAANG Company', j.job_title AS Position,  
                    uinp.education_level AS 'Education Level',
                    uinp.years_of_exp AS 'Years of Experience',
                    uinp.office_location AS 'Office Location', uinp.salary as 'Salary ($)'
                    FROM UserInput as uinp
                    JOIN Job as j ON uinp.job_id = j.job_id
                    JOIN Company as c ON j.company_id = c.company_id
                    WHERE c.company_name LIKE ", input$dbqco," 
                    AND j.job_title LIKE ", input$dbqjob,"
                    AND uinp.education_level LIKE ", input$dbqedu," 
                    AND uinp.years_of_exp LIKE ", input$dbqexp,"
                    AND uinp.office_location LIKE ", input$dbqoffice,"
                    ORDER BY uinp.salary DESC;", sep = "")
    
    data <- dbGetQuery(db,query)
    
    output$mytableDBQ <- DT::renderDataTable({ data })
    
  })
  
  # Salary Analytics Tab Query
  observeEvent(input$AVGquery, {
    # open DB connection
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
    
    # browser()
    query <- paste("", input$AVGchoice,"", sep = "")
    
    data <- dbGetQuery(db,query)
    
    output$AVGplot <- renderPlot({ data %>%
        ggplot(aes(x = reorder(data[,1], -data[,2]), y = data[,2], fill = data[,1]))+
          geom_col(color = "black")+  
          #coord_cartesian(ylim = c(120000,260000))+
          scale_y_continuous() +
          #scale_fill_gradient(low = "#90EE90", high = "#355E3B",)+
          geom_text(aes(label = data[,2]), vjust = 1.5, color = "white")+
          labs(y = "Average Salary ($)", size = 14)+
          theme(axis.title.x=element_blank(),
                axis.ticks.x=element_blank(),
                axis.text.x = element_text(angle = 90, size = 15),
                legend.position = "none") })
    
  })
  
  # User Settings Tab - Find Entries Query
  observeEvent(input$UserEntries, {
    # Open DB connection
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
    
    # browser()
    query <- paste("SELECT uinp.entry_id AS 'Entry Number',
                           uinf.first_name + ' ' + uinf.last_name AS 'Name', 
                           c.company_name as 'FAANG Company', j.job_title AS Position, 
                           uinp.education_level AS 'Education Level',
                           uinp.years_of_exp AS 'Years of Experience',
                           uinp.office_location AS 'Office Location', uinp.salary AS 'Salary ($)'
                    FROM UserInput AS uinp
                    JOIN UserInfo AS uinf ON uinp.user_id = uinf.user_id
                    JOIN Job as j ON uinp.job_id = j.job_id
                    JOIN Company as c ON j.company_id = c.company_id
                    WHERE uinp.user_id = " ,input$EntryQuery, ";", sep = "")
    
    data <- dbGetQuery(db,query)
    
    output$myEntries <- DT::renderDataTable({ data })
    
  })
  
  # User Settings Tab - Edit Entry Query 1
  observeEvent(input$EntryEdit1, {
    # Open DB connection
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
    
    # browser()
    query <- paste("UPDATE UserInput
                    SET ", input$EntryEditSelect," = ", input$EEOedit,"
                    WHERE user_id = ", input$editUID," 
                    AND entry_id = ", input$editEntryID,";", sep = "")
    
    data <- dbGetQuery(db,query)
    
    output$EditSuccess1 <- renderText({"Your entry has been edited."})
    
  })
  
  # User Settings Tab - Edit Entry Query 2
  observeEvent(input$EntryEdit2, {
    # Open DB connection
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
    
    # browser()
    query <- paste("UPDATE UserInput
                    SET salary = ", input$SALedit,"
                    WHERE user_id = ", input$editUID," 
                    AND entry_id = ", input$editEntryID,";", sep = "")
    
    data <- dbGetQuery(db,query)
    
    output$EditSuccess2 <- renderText({"Your entry has been edited."})
    
  })
  
  # User Settings Tab - Delete Entry Query
  observeEvent(input$EntryDelete, {
    # Open DB connection
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
    
    # browser()
    query <- paste("DELETE
                    FROM UserInput
                    WHERE user_id = " ,input$deleteUID, "
                    AND entry_id = " ,input$deleteEntryID, ";", sep = "")
    
    data <- dbGetQuery(db,query)
    
    output$DeleteSuccess <- renderText({"Your entry has been deleted."})
    
  })
  
  # User Settings Tab - Edit User Info Query 1
  observeEvent(input$UserEdit1, {
    # Open DB connection
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
    
    # browser()
    query <- paste("UPDATE UserInfo
                    SET ", input$UserEditSelect," = '", input$UserTextEdit,"'
                    WHERE user_id = ", input$editUserInfo,";", sep = "")
    
    data <- dbGetQuery(db,query)
    
    output$UserEditSuccess1 <- renderText({"Your information has been edited."})
    
  })
  
  # User Settings Tab - Edit User Info Query 2
  observeEvent(input$UserEdit2, {
    # Open DB connection
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
    
    # browser()
    query <- paste("UPDATE UserInfo
                    SET gender = ", input$GenderEdit,"
                    WHERE user_id = ", input$editUserInfo,";", sep = "")
    
    data <- dbGetQuery(db,query)
    
    output$UserEditSuccess2 <- renderText({"Your information has been edited."})
    
  })
  
  # User Settings Tab - Edit User Info Query 3
  observeEvent(input$UserEdit3, {
    # Open DB connection
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
    
    # browser()
    query <-paste("UPDATE UserInfo
                    SET age = ", input$AgeEdit,"
                    WHERE user_id = ", input$editUserInfo,";", sep = "")
    
    data <- dbGetQuery(db,query)
    
    output$UserEditSuccess3 <- renderText({"Your information has been edited."})
    
  })
  
  # User Settings Tab - Edit User Info Query 4
  observeEvent(input$UserInfoCheck, {
    # Open DB connection
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
    
    # browser()
    query <- paste("SELECT first_name + ' ' + last_name AS 'Name',
                    email_address AS 'Email Address',
                    gender AS 'Gender', age AS 'Age'
                    FROM UserInfo
                    WHERE user_id = ", input$editUserInfo,";", sep = "")
    
    data <- dbGetQuery(db,query)
    
    output$myUserInfo <- DT::renderDataTable({ data })
    
  })
  
  # User Settings Tab - Forgot User ID Query
  observeEvent(input$FindUser, {
    # Open DB connection
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
    
    # browser()
    query <- paste("SELECT uinf.user_id 
                    FROM UserInfo AS uinf 
                    WHERE uinf.first_name = '" ,input$forgot1, "' 
                    AND uinf.last_name = '" ,input$forgot2, "';", sep = "")
    
    data <- dbGetQuery(db,query)
    
    output$userIDforgot <- renderText({ data[1,1] })
    
  })
}

shinyApp(ui, server)
