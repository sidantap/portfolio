library(shiny)
library(DT)
library(readxl)
library(readr)
library(dplyr)
library(shinyjs)

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
        padding: calc(var(--spacing-unit) * 4) 0;
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
        width: 120px;
        height: 48px;
        background-color: var(--atlas-gold);
        border-radius: var(--radius-md);
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: var(--shadow-sm);
        font-weight: 800;
        font-size: 0.6rem;
        color: var(--atlas-navy);
        text-align: center;
        line-height: 1.1;
        letter-spacing: 0.5px;
      }

      .dashboard-title {
        font-size: 1.5rem;
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
        padding: calc(var(--spacing-unit) * 2) calc(var(--spacing-unit) * 4);
        background: none;
        border: none;
        color: rgba(255, 255, 255, 0.8);
        cursor: pointer;
        border-radius: var(--radius-md);
        transition: all 0.3s ease;
        font-size: 0.9rem;
        font-weight: 500;
      }

      .nav-tab:hover {
        color: var(--atlas-white);
        background-color: rgba(255, 255, 255, 0.15);
      }

      .nav-tab.active {
        color: var(--atlas-navy);
        background-color: var(--atlas-white);
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
        padding: calc(var(--spacing-unit) * 8);
        box-shadow: var(--shadow-md);
        border: 1px solid var(--border-color);
        margin-bottom: calc(var(--spacing-unit) * 8);
        width: 100%;
        box-sizing: border-box;
      }

      /* Section Styles */
      .section-title {
        font-size: 1.25rem;
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
        height: 20px;
        background-color: var(--atlas-gold);
        margin-right: calc(var(--spacing-unit) * 3);
        border-radius: 2px;
      }

      /* Form Inputs - Apply to Shiny's default classes */
      .form-control, 
      input[type='text'], 
      input[type='email'] {
        padding: calc(var(--spacing-unit) * 3) calc(var(--spacing-unit) * 4) !important;
        border: 1px solid var(--border-color) !important;
        border-radius: var(--radius-md) !important;
        font-size: 1rem !important;
        transition: all 0.2s ease !important;
        background-color: var(--bg-subtle) !important;
        color: var(--text-primary) !important;
        width: 100% !important;
        box-sizing: border-box !important;
      }

      /* Separate styling for select inputs to fix dropdown alignment */
      select.form-control {
        padding: calc(var(--spacing-unit) * 3) calc(var(--spacing-unit) * 4) !important;
        border: 1px solid var(--border-color) !important;
        border-radius: var(--radius-md) !important;
        font-size: 1rem !important;
        transition: all 0.2s ease !important;
        background-color: var(--bg-subtle) !important;
        color: var(--text-primary) !important;
        width: 100% !important;
        box-sizing: border-box !important;
        height: auto !important;
        line-height: normal !important;
        vertical-align: top !important;
      }

      /* Fix for selectize inputs */
      .selectize-control .selectize-input {
        padding: calc(var(--spacing-unit) * 3) calc(var(--spacing-unit) * 4) !important;
        border: 1px solid var(--border-color) !important;
        border-radius: var(--radius-md) !important;
        font-size: 1rem !important;
        transition: all 0.2s ease !important;
        background-color: var(--bg-subtle) !important;
        color: var(--text-primary) !important;
        width: 100% !important;
        box-sizing: border-box !important;
        min-height: auto !important;
        line-height: 1.6 !important;
        vertical-align: top !important;
      }

      .selectize-control .selectize-input input {
        font-size: 1rem !important;
        line-height: 1.6 !important;
      }

      /* Focus states */
      .form-control:focus, 
      input[type='text']:focus, 
      input[type='email']:focus {
        outline: none !important;
        border-color: var(--border-focus) !important;
        background-color: var(--bg-card) !important;
        box-shadow: 0 0 0 3px rgba(245, 180, 0, 0.2) !important;
      }

      select.form-control:focus {
        outline: none !important;
        border-color: var(--border-focus) !important;
        background-color: var(--bg-card) !important;
        box-shadow: 0 0 0 3px rgba(245, 180, 0, 0.2) !important;
      }

      .selectize-control .selectize-input.focus {
        outline: none !important;
        border-color: var(--border-focus) !important;
        background-color: var(--bg-card) !important;
        box-shadow: 0 0 0 3px rgba(245, 180, 0, 0.2) !important;
      }

      /* Action Buttons */
      .btn-atlas-primary {
        background-color: var(--atlas-navy) !important;
        color: var(--atlas-white) !important;
        border-color: var(--atlas-navy) !important;
        padding: calc(var(--spacing-unit) * 2.5) calc(var(--spacing-unit) * 4) !important;
        border-radius: var(--radius-md) !important;
        font-weight: 600 !important;
        transition: all 0.2s ease !important;
      }

      .btn-atlas-primary:hover {
        background-color: var(--atlas-navy-light) !important;
        border-color: var(--atlas-navy-light) !important;
        color: var(--atlas-white) !important;
      }

      .btn-atlas-gold {
        background-color: var(--atlas-gold) !important;
        color: var(--atlas-navy) !important;
        border-color: var(--atlas-gold) !important;
        padding: calc(var(--spacing-unit) * 2.5) calc(var(--spacing-unit) * 4) !important;
        border-radius: var(--radius-md) !important;
        font-weight: 600 !important;
        transition: all 0.2s ease !important;
      }

      .btn-atlas-gold:hover {
        background-color: var(--atlas-gold-dark) !important;
        border-color: var(--atlas-gold-dark) !important;
        color: var(--atlas-navy) !important;
      }

      .btn-clear {
        background-color: transparent !important;
        color: var(--text-secondary) !important;
        border-color: var(--border-color) !important;
        padding: calc(var(--spacing-unit) * 2.5) calc(var(--spacing-unit) * 4) !important;
        border-radius: var(--radius-md) !important;
        font-weight: 600 !important;
        transition: all 0.2s ease !important;
      }

      .btn-clear:hover {
        background-color: var(--bg-subtle) !important;
        border-color: #a0aec0 !important;
        color: var(--text-secondary) !important;
      }

      /* File Input Styling */
      .shiny-input-container {
        width: auto !important;
      }

      .file-input-wrapper {
        position: relative;
        display: inline-block;
      }

      .file-input-wrapper .shiny-input-container {
        display: none;
      }

      .file-input-button {
        background-color: var(--atlas-gold);
        color: var(--atlas-navy);
        border: 1px solid var(--atlas-gold);
        padding: calc(var(--spacing-unit) * 2.5) calc(var(--spacing-unit) * 4);
        border-radius: var(--radius-md);
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s ease;
        display: inline-flex;
        align-items: center;
        gap: calc(var(--spacing-unit) * 2);
        font-size: 0.9rem;
      }

      .file-input-button:hover {
        background-color: var(--atlas-gold-dark);
        border-color: var(--atlas-gold-dark);
      }

      /* Status Badges */
      .status-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 4px 10px;
        border-radius: 12px;
        font-size: 0.75rem;
        font-weight: 600;
        white-space: nowrap;
      }

      .status-badge::before {
        content: '';
        width: 8px;
        height: 8px;
        border-radius: 50%;
      }

      .status-active {
        background-color: var(--success-bg);
        color: var(--success-text);
      }
      .status-active::before {
        background-color: var(--success-text);
      }

      .status-loa {
        background-color: #fffbeb;
        color: #b45309;
      }
      .status-loa::before {
        background-color: #d97706;
      }

      /* Filter Controls */
      .filter-controls {
        display: grid;
        grid-template-columns: 2fr 1fr 1fr;
        gap: calc(var(--spacing-unit) * 6);
        margin-bottom: calc(var(--spacing-unit) * 6);
        padding-bottom: calc(var(--spacing-unit) * 6);
        border-bottom: 1px solid var(--border-color);
      }

      .filter-group {
        display: flex;
        flex-direction: column;
        gap: calc(var(--spacing-unit) * 2);
        min-width: 0;
      }

      .filter-label {
        font-weight: 500;
        color: var(--text-secondary);
        font-size: 0.9rem;
      }

      /* Status Tabs */
      .status-tabs {
        display: flex;
        gap: calc(var(--spacing-unit) * 2);
        flex-wrap: wrap;
      }

      .status-tab {
        padding: calc(var(--spacing-unit) * 2) calc(var(--spacing-unit) * 4) !important;
        border: 1px solid var(--border-color) !important;
        background-color: var(--bg-card) !important;
        color: var(--text-secondary) !important;
        border-radius: var(--radius-md) !important;
        cursor: pointer !important;
        font-weight: 500 !important;
        transition: all 0.2s ease !important;
        white-space: nowrap;
      }

      .status-tab:hover {
        background-color: var(--bg-subtle) !important;
        border-color: #a0aec0 !important;
      }

      .status-tab.active {
        background-color: var(--atlas-navy-light) !important;
        color: var(--atlas-white) !important;
        border-color: var(--atlas-navy-light) !important;
      }

      /* DataTable Styling */
      .dataTables_wrapper {
        font-family: inherit;
        width: 100% !important;
        overflow-x: auto;
      }

      .dataTables_wrapper .dataTables_length,
      .dataTables_wrapper .dataTables_filter,
      .dataTables_wrapper .dataTables_info,
      .dataTables_wrapper .dataTables_processing,
      .dataTables_wrapper .dataTables_paginate {
        color: var(--text-secondary);
      }

      .dataTables_wrapper .dataTables_paginate .paginate_button {
        color: var(--text-secondary) !important;
        border: 1px solid var(--border-color);
        background: var(--bg-card);
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

      /* Form Grid - Fixed Layout */
      .form-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: calc(var(--spacing-unit) * 4);
        margin-bottom: calc(var(--spacing-unit) * 6);
        width: 100%;
      }

      @media (min-width: 1200px) {
        .form-grid {
          grid-template-columns: repeat(6, 1fr);
        }
      }

      @media (max-width: 1199px) and (min-width: 768px) {
        .form-grid {
          grid-template-columns: repeat(3, 1fr);
        }
      }

      @media (max-width: 767px) {
        .form-grid {
          grid-template-columns: 1fr;
        }
        .filter-controls {
          grid-template-columns: 1fr;
        }
        .main-content {
          padding: calc(var(--spacing-unit) * 6) calc(var(--spacing-unit) * 4);
        }
        .header-content {
          padding: 0 calc(var(--spacing-unit) * 4);
        }
      }

      /* Input Groups */
      .input-group {
        display: flex;
        flex-direction: column;
        gap: calc(var(--spacing-unit) * 2);
        min-width: 0;
        width: 100%;
      }

      .input-label {
        font-weight: 500;
        color: var(--text-secondary);
        font-size: 0.9rem;
      }

      /* Page Header */
      .page-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: calc(var(--spacing-unit) * 6);
        width: 100%;
      }

      .page-actions {
        display: flex;
        gap: calc(var(--spacing-unit) * 4);
      }

      /* Responsive adjustments */
      @media (max-width: 992px) {
        .page-header {
          flex-direction: column;
          align-items: flex-start;
          gap: calc(var(--spacing-unit) * 4);
        }
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
                  h1(class = "dashboard-title", "FAA Compliance Dashboard")
              ),
              # Navigation
              div(class = "nav-tabs",
                  div(class = "nav-tab", "🏠 Home"),
                  div(class = "nav-tab", "📋 Audit Log"),
                  div(class = "nav-tab active", "👥 Employee Management")
              )
          )
      ),
      
      # Main Content
      div(class = "main-content",
          # Page Header
          div(class = "page-header",
              h2(class = "section-title", "Manage Employee Pool"),
              div(class = "page-actions",
                  div(class = "file-input-wrapper",
                      fileInput("file_upload", NULL, 
                                accept = c(".csv", ".xlsx", ".xls"),
                                buttonLabel = "Upload CSV/XLSX"),
                      tags$button(
                        type = "button",
                        class = "file-input-button",
                        onclick = "document.getElementById('file_upload').click();",
                        "📤 Upload CSV/XLSX"
                      )
                  )
              )
          ),
          
          # Add Employee Form
          div(class = "card",
              h3("Add New Employee", style = "font-size: 1.125rem; font-weight: 600; color: var(--text-primary); margin-bottom: calc(var(--spacing-unit) * 6); padding-bottom: calc(var(--spacing-unit) * 3); border-bottom: 1px solid var(--border-color);"),
              div(class = "form-grid",
                  div(class = "input-group",
                      tags$label("Employee ID", class = "input-label"),
                      textInput("employee_id", NULL)
                  ),
                  div(class = "input-group",
                      tags$label("Full Name", class = "input-label"),
                      textInput("employee_name", NULL, placeholder = "First Last")
                  ),
                  div(class = "input-group",
                      tags$label("Occupation", class = "input-label"),
                      textInput("employee_occupation", NULL)
                  ),
                  div(class = "input-group",
                      tags$label("Base", class = "input-label"),
                      selectInput("employee_base", NULL, 
                                  choices = c("JFK", "MIA", "CVG", "ANC"),
                                  selected = "JFK")
                  ),
                  div(class = "input-group",
                      tags$label("Status", class = "input-label"),
                      selectInput("employee_status", NULL,
                                  choices = c("Active" = "Active", "Leave of Absence (LOA)" = "LOA"),
                                  selected = "Active")
                  ),
                  div(class = "input-group",
                      tags$label("Email Address", class = "input-label"),
                      textInput("employee_email", NULL)
                  )
              ),
              div(style = "display: flex; justify-content: flex-end; gap: calc(var(--spacing-unit) * 3); padding-top: calc(var(--spacing-unit) * 6); margin-top: calc(var(--spacing-unit) * 6); border-top: 1px solid var(--border-color);",
                  actionButton("clear_form", "Clear Form", class = "btn-clear"),
                  actionButton("add_employee", "Add Employee", class = "btn-atlas-primary")
              )
          ),
          
          # Filter & Tabs Card
          div(class = "card",
              div(class = "filter-controls",
                  div(class = "filter-group",
                      tags$label("Search", class = "filter-label"),
                      textInput("search_filter", NULL, placeholder = "ID, Name, Occupation...")
                  ),
                  div(class = "filter-group",
                      tags$label("Occupation", class = "filter-label"),
                      selectInput("occupation_filter", NULL,
                                  choices = c("All Occupations" = "all", "Pilot", "Mechanic", "Ground Crew", "Supervisor"),
                                  selected = "all")
                  ),
                  div(class = "filter-group",
                      tags$label("Base", class = "filter-label"),
                      selectInput("base_filter", NULL,
                                  choices = c("All Bases" = "all", "JFK", "MIA", "CVG", "ANC"),
                                  selected = "all")
                  )
              ),
              div(class = "status-tabs",
                  actionButton("status_all", "All Employees", class = "status-tab active"),
                  actionButton("status_active", "Active", class = "status-tab"),
                  actionButton("status_loa", "Leave of Absence (LOA)", class = "status-tab")
              )
          ),
          
          # Employee Table
          div(class = "card",
              DT::dataTableOutput("employee_table")
          )
      )
  )
)

# Define Server (same as before)
server <- function(input, output, session) {
  # Reactive values to store employee data
  employees <- reactiveVal(data.frame(
    ID = character(0),
    Name = character(0),
    Occupation = character(0),
    Base = character(0),
    Status = character(0),
    Email = character(0),
    stringsAsFactors = FALSE
  ))
  
  # Current status filter
  current_status <- reactiveVal("all")
  
  # Add employee functionality
  observeEvent(input$add_employee, {
    req(input$employee_id, input$employee_name, input$employee_occupation, 
        input$employee_base, input$employee_status, input$employee_email)
    
    current_data <- employees()
    
    # Check if employee ID already exists
    if (input$employee_id %in% current_data$ID) {
      showNotification("Employee ID already exists. Please use a different ID.", type = "error")
      return()
    }
    
    # Add new employee
    new_employee <- data.frame(
      ID = input$employee_id,
      Name = input$employee_name,
      Occupation = input$employee_occupation,
      Base = input$employee_base,
      Status = input$employee_status,
      Email = input$employee_email,
      stringsAsFactors = FALSE
    )
    
    updated_data <- rbind(new_employee, current_data)
    employees(updated_data)
    
    showNotification("Employee added successfully!", type = "message")
  })
  
  # Clear form functionality
  observeEvent(input$clear_form, {
    updateTextInput(session, "employee_id", value = "")
    updateTextInput(session, "employee_name", value = "")
    updateTextInput(session, "employee_occupation", value = "")
    updateSelectInput(session, "employee_base", selected = "JFK")
    updateSelectInput(session, "employee_status", selected = "Active")
    updateTextInput(session, "employee_email", value = "")
  })
  
  # File upload functionality
  observeEvent(input$file_upload, {
    req(input$file_upload)
    
    ext <- tools::file_ext(input$file_upload$datapath)
    
    tryCatch({
      if (ext == "csv") {
        uploaded_data <- read_csv(input$file_upload$datapath)
      } else if (ext %in% c("xlsx", "xls")) {
        uploaded_data <- read_excel(input$file_upload$datapath)
      } else {
        showNotification("Unsupported file type. Please upload a CSV or XLSX file.", type = "error")
        return()
      }
      
      # Check required columns
      required_cols <- c("Employee ID", "Name", "Occupation", "Base", "Status")
      if (!all(required_cols %in% names(uploaded_data))) {
        missing_cols <- setdiff(required_cols, names(uploaded_data))
        showNotification(paste("Missing required columns:", paste(missing_cols, collapse = ", ")), type = "error")
        return()
      }
      
      # Process uploaded data
      processed_data <- uploaded_data %>%
        select(`Employee ID`, Name, Occupation, Base, Status, Email = if("Email" %in% names(uploaded_data)) Email else NA) %>%
        rename(ID = `Employee ID`) %>%
        filter(!is.na(ID), !is.na(Name), !is.na(Occupation), !is.na(Base)) %>%
        mutate(
          ID = as.character(ID),
          Email = if(is.na(Email)) "" else as.character(Email)
        )
      
      # Check for duplicates with existing data
      current_data <- employees()
      existing_ids <- current_data$ID
      duplicate_ids <- processed_data$ID[processed_data$ID %in% existing_ids]
      
      if (length(duplicate_ids) > 0) {
        processed_data <- processed_data[!processed_data$ID %in% duplicate_ids, ]
        showNotification(paste("Skipped", length(duplicate_ids), "duplicate Employee IDs"), type = "warning")
      }
      
      if (nrow(processed_data) > 0) {
        updated_data <- rbind(current_data, processed_data)
        employees(updated_data)
        showNotification(paste("Successfully added", nrow(processed_data), "employees"), type = "message")
      } else {
        showNotification("No valid employee records found to add", type = "warning")
      }
      
    }, error = function(e) {
      showNotification("Error processing file. Please check the file format.", type = "error")
    })
  })
  
  # Status tab functionality
  observeEvent(input$status_all, {
    current_status("all")
    runjs("
      $('.status-tab').removeClass('active');
      $('#status_all').addClass('active');
    ")
  })
  
  observeEvent(input$status_active, {
    current_status("Active")
    runjs("
      $('.status-tab').removeClass('active');
      $('#status_active').addClass('active');
    ")
  })
  
  observeEvent(input$status_loa, {
    current_status("LOA")
    runjs("
      $('.status-tab').removeClass('active');
      $('#status_loa').addClass('active');
    ")
  })
  
  # Filtered data for table
  filtered_data <- reactive({
    data <- employees()
    
    if (nrow(data) == 0) return(data)
    
    # Apply search filter
    if (!is.null(input$search_filter) && input$search_filter != "") {
      search_term <- tolower(input$search_filter)
      data <- data[
        grepl(search_term, tolower(data$ID)) |
          grepl(search_term, tolower(data$Name)) |
          grepl(search_term, tolower(data$Occupation)), 
      ]
    }
    
    # Apply occupation filter
    if (!is.null(input$occupation_filter) && input$occupation_filter != "all") {
      data <- data[data$Occupation == input$occupation_filter, ]
    }
    
    # Apply base filter
    if (!is.null(input$base_filter) && input$base_filter != "all") {
      data <- data[data$Base == input$base_filter, ]
    }
    
    # Apply status filter
    if (current_status() != "all") {
      data <- data[data$Status == current_status(), ]
    }
    
    return(data)
  })
  
  # Render employee table
  output$employee_table <- DT::renderDataTable({
    data <- filtered_data()
    
    if (nrow(data) == 0) {
      return(DT::datatable(
        data.frame(Message = "No employees found. Try adjusting your search criteria."),
        options = list(
          dom = 't',
          ordering = FALSE,
          columnDefs = list(list(className = 'dt-center', targets = 0))
        ),
        rownames = FALSE
      ))
    }
    
    # Add status badges and action buttons
    data$Status <- sapply(data$Status, function(status) {
      if (status == "Active") {
        paste0('<span class="status-badge status-active">', status, '</span>')
      } else if (status == "LOA") {
        paste0('<span class="status-badge status-loa">Leave of Absence</span>')
      } else {
        paste0('<span class="status-badge">', status, '</span>')
      }
    })
    
    # Add action buttons
    data$Actions <- paste0(
      '<button class="btn btn-sm btn-outline-primary" onclick="editEmployee(\'', data$ID, '\')">✏️</button> ',
      '<button class="btn btn-sm btn-outline-danger" onclick="removeEmployee(\'', data$ID, '\')">🗑️</button>'
    )
    
    DT::datatable(
      data,
      options = list(
        pageLength = 10,
        lengthMenu = c(10, 25, 50, 100),
        dom = 'Bfrtip',
        scrollX = TRUE,
        columnDefs = list(
          list(className = 'dt-center', targets = c(4, 5)) # Status and Actions columns
        )
      ),
      escape = FALSE,
      rownames = FALSE
    )
  })
  
  # JavaScript for remove functionality
  observe({
    runjs("
      window.removeEmployee = function(employeeId) {
        if (confirm('Are you sure you want to remove this employee?')) {
          Shiny.setInputValue('remove_employee_id', employeeId, {priority: 'event'});
        }
      };
      
      window.editEmployee = function(employeeId) {
        alert('Edit functionality for employee ' + employeeId + ' is not yet implemented.');
      };
    ")
  })
  
  # Handle employee removal
  observeEvent(input$remove_employee_id, {
    req(input$remove_employee_id)
    
    current_data <- employees()
    updated_data <- current_data[current_data$ID != input$remove_employee_id, ]
    employees(updated_data)
    
    showNotification("Employee removed successfully!", type = "message")
  })
}

# Run the application
shinyApp(ui = ui, server = server)