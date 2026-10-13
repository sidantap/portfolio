library(shiny)
library(DT)
library(dplyr)
library(shinyjs)
library(lubridate)

# Define UI
ui <- fluidPage(
  # Enable shinyjs
  useShinyjs(),
  
  # Include custom CSS
  tags$head(
    tags$style(HTML("
      /* Atlas Air Brand Colors & Design Tokens */
      :root {
        --atlas-navy: #002554;
        --atlas-navy-light: #003366;
        --atlas-white: #ffffff;
        --atlas-gold: #f5b400;
        --atlas-gold-dark: #e6a200;
        --atlas-light-blue: #6b99d6;
        --text-primary: #1a202c;
        --text-secondary: #4a5568;
        --text-tertiary: #a0aec0;
        --bg-body: #f7fafc;
        --bg-card: #ffffff;
        --bg-subtle: #edf2f7;
        --border-color: #e2e8f0;
        --border-focus: var(--atlas-gold);
        --success-bg: #f0fff4;
        --success-text: #2f855a;
        --success-border: #9ae6b4;
        --danger-bg: #fff5f5;
        --danger-text: #c53030;
        --danger-border: #feb2b2;
        --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
        --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
        --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        --radius-md: 8px;
        --radius-lg: 12px;
        --radius-xl: 16px;
        --spacing-unit: 4px;
      }

      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }

      body {
        font-family: 'Inter', 'Segoe UI', system-ui, -apple-system, sans-serif;
        line-height: 1.6;
        color: var(--text-primary);
        background-color: var(--bg-body);
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
        overflow-x: hidden;
        font-size: 16px; /* Increased base font size */
        zoom: 1.1; /* Overall zoom for better readability */
      }

      /* Fix Shiny container */
      .container-fluid {
        padding: 0 !important;
        max-width: 100vw !important;
        overflow-x: hidden !important;
      }

      .dashboard-layout {
        display: flex;
        flex-direction: column;
        min-height: 100vh;
        width: 100%;
        max-width: 100vw;
        overflow-x: hidden;
      }

      /* Header Styles */
      .header {
        background-color: var(--atlas-navy);
        color: var(--atlas-white);
        padding: calc(var(--spacing-unit) * 5) 0; /* Increased padding */
        box-shadow: var(--shadow-md);
        position: sticky;
        top: 0;
        z-index: 100;
        border-bottom: 2px solid var(--atlas-gold);
        width: 100%;
      }

      .header-content {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: calc(var(--spacing-unit) * 8);
        max-width: 1400px;
        margin: 0 auto;
        padding: 0 calc(var(--spacing-unit) * 8);
        width: 100%;
      }

      .logo-section {
        display: flex;
        align-items: center;
        gap: calc(var(--spacing-unit) * 4);
      }

      .logo-placeholder {
        width: 140px; /* Increased size */
        height: 56px; /* Increased size */
        background-color: var(--atlas-gold);
        border-radius: var(--radius-md);
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: var(--shadow-sm);
        font-weight: 800;
        font-size: 0.7rem; /* Increased font size */
        color: var(--atlas-navy);
        text-align: center;
        line-height: 1.1;
        letter-spacing: 0.5px;
      }

      .dashboard-title {
        font-size: 1.75rem; /* Increased from 1.5rem */
        font-weight: 600;
        margin: 0;
        white-space: nowrap;
      }

      /* Navigation Tabs */
      .nav-tabs {
        display: flex;
        background-color: rgba(255, 255, 255, 0.1);
        border-radius: var(--radius-lg);
        padding: var(--spacing-unit);
      }

      .nav-tab {
        position: relative;
        display: flex;
        align-items: center;
        gap: calc(var(--spacing-unit) * 2);
        padding: calc(var(--spacing-unit) * 3) calc(var(--spacing-unit) * 5); /* Increased padding */
        background: none;
        border: none;
        color: rgba(255, 255, 255, 0.8);
        cursor: pointer;
        border-radius: var(--radius-md);
        transition: all 0.3s ease;
        font-size: 1rem; /* Increased from 0.9rem */
        font-weight: 500;
      }

      .nav-tab:hover {
        color: var(--atlas-white);
        background-color: rgba(255, 255, 255, 0.15);
      }

      .nav-tab.active {
        color: var(--atlas-navy);
        background-color: var(--atlas-gold);
        box-shadow: var(--shadow-md);
      }

      /* Main Content */
      .main-content {
        padding: calc(var(--spacing-unit) * 10) calc(var(--spacing-unit) * 8);
        flex-grow: 1;
        max-width: 1400px;
        margin: 0 auto;
        width: 100%;
        box-sizing: border-box;
      }

      /* Card Styles */
      .card {
        background-color: var(--bg-card);
        border-radius: var(--radius-xl);
        padding: calc(var(--spacing-unit) * 10); /* Increased padding */
        box-shadow: var(--shadow-md);
        border: 1px solid var(--border-color);
        margin-bottom: calc(var(--spacing-unit) * 8);
        width: 100%;
        box-sizing: border-box;
      }

      /* Section Styles */
      .section-title {
        font-size: 1.5rem; /* Increased from 1.25rem */
        font-weight: 600;
        color: var(--text-primary);
        margin-bottom: calc(var(--spacing-unit) * 6);
        padding-bottom: calc(var(--spacing-unit) * 2);
        border-bottom: 1px solid var(--border-color);
        display: flex;
        align-items: center;
      }

      .section-title::before {
        content: '';
        display: inline-block;
        width: 4px;
        height: 24px; /* Increased height */
        background-color: var(--atlas-gold);
        margin-right: calc(var(--spacing-unit) * 3);
        border-radius: 2px;
      }

      /* Form Inputs */
      .form-control, 
      input[type='text'], 
      input[type='email'],
      input[type='date'] {
        padding: calc(var(--spacing-unit) * 4) calc(var(--spacing-unit) * 5) !important; /* Increased padding */
        border: 1px solid var(--border-color) !important;
        border-radius: var(--radius-md) !important;
        font-size: 1.1rem !important; /* Increased from 1rem */
        transition: all 0.2s ease !important;
        background-color: var(--bg-subtle) !important;
        color: var(--text-primary) !important;
        width: 100% !important;
        box-sizing: border-box !important;
        min-height: 48px !important; /* Increased minimum height */
      }

      .form-control:focus, 
      input[type='text']:focus, 
      input[type='email']:focus,
      input[type='date']:focus {
        outline: none !important;
        border-color: var(--border-focus) !important;
        background-color: var(--bg-card) !important;
        box-shadow: 0 0 0 3px rgba(245, 180, 0, 0.2) !important;
      }

      /* Download Button */
      .download-button {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: calc(var(--spacing-unit) * 2);
        padding: calc(var(--spacing-unit) * 3) calc(var(--spacing-unit) * 4); /* Increased padding */
        background-color: var(--atlas-white);
        color: var(--atlas-navy);
        border: 1px solid var(--atlas-gold-dark);
        border-radius: var(--radius-md);
        font-size: 0.9rem; /* Increased from 0.8rem */
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s ease;
        min-height: 40px; /* Added minimum height */
      }

      .download-button:hover {
        background-color: var(--atlas-gold-dark);
        border-color: var(--atlas-gold-dark);
        transform: translateY(-1px);
        box-shadow: var(--shadow-md);
      }

      /* DataTable Styling */
      .dataTables_wrapper {
        font-family: inherit;
        width: 100% !important;
        overflow-x: auto;
        font-size: 1rem !important; /* Increased table font size */
      }

      .dataTables_wrapper table {
        font-size: 1rem !important; /* Ensure table inherits larger font */
      }

      .dataTables_wrapper th {
        font-size: 0.95rem !important; /* Increased header font size */
        padding: 12px 8px !important; /* Increased padding */
      }

      .dataTables_wrapper td {
        font-size: 1rem !important; /* Increased cell font size */
        padding: 12px 8px !important; /* Increased padding */
        line-height: 1.5 !important;
      }

      .dataTables_wrapper .dataTables_length,
      .dataTables_wrapper .dataTables_filter,
      .dataTables_wrapper .dataTables_info,
      .dataTables_wrapper .dataTables_processing,
      .dataTables_wrapper .dataTables_paginate {
        color: var(--text-secondary);
        font-size: 1rem !important; /* Increased font size for controls */
      }

      .dataTables_wrapper .dataTables_length select,
      .dataTables_wrapper .dataTables_filter input {
        font-size: 1rem !important; /* Increased font size for inputs */
        padding: 6px 8px !important;
      }

      .dataTables_wrapper .dataTables_paginate .paginate_button {
        color: var(--text-secondary) !important;
        border: 1px solid var(--border-color);
        background: var(--bg-card);
        font-size: 1rem !important; /* Increased pagination font size */
        padding: 8px 12px !important; /* Increased padding */
      }

      .dataTables_wrapper .dataTables_paginate .paginate_button:hover {
        color: var(--atlas-navy) !important;
        border: 1px solid var(--atlas-gold);
        background: var(--atlas-gold);
      }

      .dataTables_wrapper .dataTables_paginate .paginate_button.current {
        color: var(--atlas-white) !important;
        border: 1px solid var(--atlas-navy);
        background: var(--atlas-navy);
      }

      /* Audit Filter Row */
      .audit-filter-row-three {
        display: grid;
        grid-template-columns: 1fr 1fr 1fr;
        gap: calc(var(--spacing-unit) * 8); /* Increased gap */
        align-items: end;
        margin-bottom: calc(var(--spacing-unit) * 6);
      }

      @media (max-width: 992px) {
        .audit-filter-row-three {
          grid-template-columns: 1fr 1fr;
          gap: calc(var(--spacing-unit) * 4);
        }
      }

      @media (max-width: 768px) {
        .audit-filter-row-three {
          grid-template-columns: 1fr;
        }
        .main-content {
          padding: calc(var(--spacing-unit) * 6) calc(var(--spacing-unit) * 4);
        }
        .header-content {
          padding: 0 calc(var(--spacing-unit) * 4);
        }
        body {
          zoom: 1.05; /* Slightly less zoom on mobile */
        }
      }

      /* Input Groups */
      .input-group {
        display: flex;
        flex-direction: column;
        gap: calc(var(--spacing-unit) * 3); /* Increased gap */
        min-width: 0;
        width: 100%;
      }

      .input-label {
        font-weight: 500;
        color: var(--text-secondary);
        font-size: 1rem; /* Increased from 0.9rem */
      }

      /* Page Header */
      .page-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: calc(var(--spacing-unit) * 8); /* Increased margin */
        width: 100%;
      }

      /* Table Card */
      .table-card {
        padding: calc(var(--spacing-unit) * 4); /* Added some padding back */
      }

      /* No Results Message */
      .no-results-message {
        text-align: center;
        padding: calc(var(--spacing-unit) * 16);
        color: var(--text-tertiary);
      }
      .no-results-message h3 {
        font-size: 1.4rem; /* Increased from 1.25rem */
        color: var(--text-secondary);
        margin-top: calc(var(--spacing-unit) * 4);
        margin-bottom: var(--spacing-unit);
      }
      .no-results-message p {
        max-width: 400px;
        margin: 0 auto;
        font-size: 1.1rem; /* Increased font size */
      }

      /* Placeholder text styling */
      ::placeholder {
        font-size: 1rem !important;
        opacity: 0.7;
      }
    "))
  ),
  
  # Dashboard Layout
  div(class = "dashboard-layout",
      # Header
      div(class = "header",
          div(class = "header-content",
              div(class = "logo-section",
                  div(class = "logo-placeholder", "ATLAS AIR"),
                  h1(class = "dashboard-title", "Drug and Alcohol Testing Portal")
              ),
              # Navigation
              div(class = "nav-tabs",
                  div(class = "nav-tab", "🏠 Home"),
                  div(class = "nav-tab active", "📋 Audit Log"),
                  div(class = "nav-tab", "👥 Employee Management")
              )
          )
      ),
      
      # Main Content
      div(class = "main-content",
          # Page Header
          div(class = "page-header",
              h2(class = "section-title", "Audit Log – Randomizer Runs")
          ),
          
          # Filter Card
          div(class = "card",
              div(class = "audit-filter-row-three",
                  div(class = "input-group",
                      tags$label("From", class = "input-label"),
                      dateInput("date_from", NULL, value = NULL)
                  ),
                  div(class = "input-group",
                      tags$label("To", class = "input-label"),
                      dateInput("date_to", NULL, value = NULL)
                  ),
                  div(class = "input-group",
                      tags$label("Performed By", class = "input-label"),
                      textInput("performed_by", NULL, placeholder = "Enter user email...")
                  )
              )
          ),
          
          # Audit Log Table
          div(class = "card table-card",
              DT::dataTableOutput("audit_table")
          )
      )
  )
)

# Define Server
server <- function(input, output, session) {
  # Mock audit log data
  audit_logs <- reactiveVal({
    data.frame(
      timestamp = as.POSIXct(c(
        "2025-07-01 10:30:00",
        "2025-06-30 15:45:12",
        "2025-06-29 11:20:35",
        "2025-06-28 09:05:18",
        "2025-06-27 18:00:00",
        "2025-06-26 13:13:13",
        "2025-06-25 16:22:45"
      )),
      user = c(
        "admin@atlasair.com",
        "jane.doe@atlasair.com",
        "robert.jones@atlasair.com",
        "admin@atlasair.com",
        "sarah.wilson@atlasair.com",
        "mike.davis@atlasair.com",
        "admin@atlasair.com"
      ),
      parameters = c(
        "Drug: 50%, Combo: 25%, Quarter: Q4 2024, Total Selected: 312",
        "Drug: 75%, Quarter: Q4 2024, Total Selected: 468",
        "Drug: 40%, Combo: 30%, Quarter: Q3 2024, Total Selected: 437",
        "Drug: 60%, Quarter: Q3 2024, Total Selected: 374",
        "Drug: 45%, Combo: 20%, Quarter: Q3 2024, Total Selected: 405",
        "Drug: 55%, Quarter: Q2 2024, Total Selected: 343",
        "Drug: 50%, Combo: 25%, Quarter: Q2 2024, Total Selected: 468"
      ),
      stringsAsFactors = FALSE
    )
  })
  
  # Filtered data for table
  filtered_data <- reactive({
    data <- audit_logs()
    
    if (nrow(data) == 0) return(data)
    
    # Apply date from filter
    if (!is.null(input$date_from)) {
      data <- data[as.Date(data$timestamp) >= input$date_from, ]
    }
    
    # Apply date to filter
    if (!is.null(input$date_to)) {
      data <- data[as.Date(data$timestamp) <= input$date_to, ]
    }
    
    # Apply user filter
    if (!is.null(input$performed_by) && input$performed_by != "") {
      search_term <- tolower(input$performed_by)
      data <- data[grepl(search_term, tolower(data$user)), ]
    }
    
    return(data)
  })
  
  # Render audit table
  output$audit_table <- DT::renderDataTable({
    data <- filtered_data()
    
    if (nrow(data) == 0) {
      return(DT::datatable(
        data.frame(Message = "No log entries found. Try adjusting your filter criteria."),
        options = list(
          dom = 't',
          ordering = FALSE,
          columnDefs = list(list(className = 'dt-center', targets = 0))
        ),
        rownames = FALSE
      ))
    }
    
    # Format timestamp for display
    data$Timestamp <- format(data$timestamp, "%Y-%m-%d %H:%M:%S")
    
    # Add download buttons
    data$Actions <- paste0(
      '<button class="download-button" onclick="downloadAuditFile(\'', 
      format(data$timestamp, "%Y-%m-%d"), 
      '\')">📥 Download</button>'
    )
    
    # Select and rename columns for display
    display_data <- data[, c("Timestamp", "user", "parameters", "Actions")]
    names(display_data) <- c("Timestamp", "User", "Parameters", "")
    
    DT::datatable(
      display_data,
      options = list(
        pageLength = 10,
        lengthMenu = c(10, 25, 50, 100),
        dom = 'Bfrtip',
        scrollX = TRUE,
        order = list(list(0, 'desc')), # Sort by timestamp descending
        columnDefs = list(
          list(className = 'dt-center', targets = 3), # Actions column
          list(width = '200px', targets = 0), # Timestamp column
          list(width = '200px', targets = 1), # User column
          list(width = '120px', targets = 3)  # Actions column
        )
      ),
      escape = FALSE,
      rownames = FALSE
    )
  })
  
  # JavaScript for download functionality
  observe({
    runjs("
      window.downloadAuditFile = function(date) {
        var fileName = 'Randomizer_Run_' + date + '_audit.pdf';
        alert('Downloading audit file: ' + fileName);
        // In a real application, this would trigger an actual file download
        // You could use Shiny's downloadHandler here
      };
    ")
  })
  
  # Optional: Add actual download functionality
  output$download_audit <- downloadHandler(
    filename = function() {
      paste("audit_log_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(filtered_data(), file, row.names = FALSE)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)