library(shiny)
library(DT)
library(dplyr)
library(shinyjs)
library(lubridate)
library(openxlsx)

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
        --spacing-unit: 3px; /* Reduced from 4px */
      }

      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }

      body {
        font-family: 'Inter', 'Segoe UI', system-ui, -apple-system, sans-serif;
        line-height: 1.4; /* Reduced from 1.6 */
        color: var(--text-primary);
        background-color: var(--bg-body);
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
        overflow-x: hidden;
        font-size: 18px; /* Increased base font size */
        zoom: 1.15; /* Increased zoom for better readability */
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
        padding: calc(var(--spacing-unit) * 2) 0; /* Reduced padding */
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
        gap: calc(var(--spacing-unit) * 6); /* Reduced gap */
        max-width: 1400px;
        margin: 0 auto;
        padding: 0 calc(var(--spacing-unit) * 6); /* Reduced padding */
        width: 100%;
      }

      .logo-section {
        display: flex;
        align-items: center;
        gap: calc(var(--spacing-unit) * 3); /* Reduced gap */
      }

      .logo-placeholder {
        width: 120px; /* Slightly reduced */
        height: 48px; /* Slightly reduced */
        background-color: var(--atlas-gold);
        border-radius: var(--radius-md);
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: var(--shadow-sm);
        font-weight: 800;
        font-size: 0.8rem; /* Increased font size */
        color: var(--atlas-navy);
        text-align: center;
        line-height: 1.1;
        letter-spacing: 0.5px;
      }

      .dashboard-title {
        font-size: 1.8rem; /* Increased font size */
        font-weight: 600;
        margin: 0;
        white-space: nowrap;
      }

      /* Navigation Tabs */
      .nav-tabs {
        display: flex;
        background-color: rgba(255, 255, 255, 0.1);
        border-radius: var(--radius-lg);
        padding: calc(var(--spacing-unit) * 0.5); /* Reduced padding */
      }

      .nav-tab {
        position: relative;
        display: flex;
        align-items: center;
        gap: calc(var(--spacing-unit) * 2);
        padding: calc(var(--spacing-unit) * 2) calc(var(--spacing-unit) * 3); /* Reduced padding */
        background: none;
        border: none;
        color: rgba(255, 255, 255, 0.8);
        cursor: pointer;
        border-radius: var(--radius-md);
        transition: all 0.3s ease;
        font-size: 1.1rem; /* Increased font size */
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
        padding: calc(var(--spacing-unit) * 4) calc(var(--spacing-unit) * 6); /* Reduced padding */
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
        padding: calc(var(--spacing-unit) * 4); /* Reduced padding */
        box-shadow: var(--shadow-md);
        border: 1px solid var(--border-color);
        margin-bottom: calc(var(--spacing-unit) * 3); /* Reduced margin */
        width: 100%;
        box-sizing: border-box;
      }

      /* Section Styles */
      .section-title {
        font-size: 1.6rem; /* Increased font size */
        font-weight: 600;
        color: var(--text-primary);
        margin-bottom: calc(var(--spacing-unit) * 3); /* Reduced margin */
        padding-bottom: calc(var(--spacing-unit) * 1.5); /* Reduced padding */
        border-bottom: 1px solid var(--border-color);
        display: flex;
        align-items: center;
      }

      .section-title::before {
        content: '';
        display: inline-block;
        width: 4px;
        height: 24px;
        background-color: var(--atlas-gold);
        margin-right: calc(var(--spacing-unit) * 2); /* Reduced margin */
        border-radius: 2px;
      }

      /* KPI Section */
      .kpi-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: calc(var(--spacing-unit) * 4); /* Reduced gap */
        margin-bottom: calc(var(--spacing-unit) * 3); /* Reduced margin */
      }

      .kpi-card {
        background-color: var(--bg-card);
        border-radius: var(--radius-lg);
        padding: calc(var(--spacing-unit) * 3); /* Reduced padding */
        box-shadow: var(--shadow-md);
        border: 1px solid var(--border-color);
        display: flex;
        flex-direction: column;
        gap: calc(var(--spacing-unit) * 2); /* Reduced gap */
        transition: all 0.3s ease;
      }

      .kpi-card:hover {
        transform: translateY(-2px);
        box-shadow: var(--shadow-lg);
        border-color: var(--atlas-gold);
      }

      .kpi-header {
        display: flex;
        align-items: center;
        gap: calc(var(--spacing-unit) * 2); /* Reduced gap */
      }

      .kpi-title {
        font-size: 1rem; /* Increased font size */
        font-weight: 500;
        color: var(--text-secondary);
      }

      .kpi-value {
        font-size: 2.2rem; /* Increased font size */
        font-weight: 700;
        color: var(--text-primary);
        line-height: 1;
      }

      .kpi-footer {
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 0.9rem; /* Increased font size */
      }

      .kpi-subtitle {
        color: var(--text-tertiary);
      }

      .kpi-trend {
        font-weight: 600;
        padding: 2px 6px;
        border-radius: 4px;
      }
      .kpi-trend.up {
        color: #2f855a;
        background-color: #f0fff4;
      }
      .kpi-trend.down {
        color: #c53030;
        background-color: #fff5f5;
      }

      .kpi-progress-bar {
        width: 50px; /* Reduced width */
        height: 4px;
        background-color: var(--bg-subtle);
        border-radius: 2px;
        overflow: hidden;
      }
      .kpi-progress {
        height: 100%;
        background-color: var(--atlas-gold);
        border-radius: 2px;
      }

      /* Form Inputs */
      .form-control, 
      input[type='number'],
      select {
        padding: calc(var(--spacing-unit) * 3) calc(var(--spacing-unit) * 4) !important; /* Reduced padding */
        border: 1px solid var(--border-color) !important;
        border-radius: var(--radius-md) !important;
        font-size: 1.2rem !important; /* Increased font size */
        transition: all 0.2s ease !important;
        background-color: var(--bg-subtle) !important;
        color: var(--text-primary) !important;
        width: 100% !important;
        box-sizing: border-box !important;
        min-height: 42px !important; /* Reduced height */
      }

      .form-control:focus, 
      input[type='number']:focus,
      select:focus {
        outline: none !important;
        border-color: var(--border-focus) !important;
        background-color: var(--bg-card) !important;
        box-shadow: 0 0 0 3px rgba(245, 180, 0, 0.2) !important;
      }

      /* Form Grid */
      .form-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: calc(var(--spacing-unit) * 4) calc(var(--spacing-unit) * 6); /* Reduced gaps */
        margin-bottom: calc(var(--spacing-unit) * 4); /* Reduced margin */
      }

      .input-group {
        display: flex;
        flex-direction: column;
        gap: calc(var(--spacing-unit) * 1.5); /* Reduced gap */
        min-width: 0;
        width: 100%;
      }

      .input-label {
        font-weight: 500;
        color: var(--text-secondary);
        font-size: 1.1rem; /* Increased font size */
      }

      /* Run Button */
      .run-button {
        display: inline-flex;
        align-items: center;
        gap: calc(var(--spacing-unit) * 2);
        background: linear-gradient(135deg, var(--atlas-navy), var(--atlas-navy-light));
        color: var(--atlas-white);
        border: none;
        padding: calc(var(--spacing-unit) * 2.5) calc(var(--spacing-unit) * 4); /* Reduced padding */
        font-size: 1.1rem; /* Increased font size */
        font-weight: 600;
        border-radius: var(--radius-md);
        cursor: pointer;
        transition: all 0.3s ease;
        box-shadow: var(--shadow-md);
        min-height: 40px; /* Reduced height */
      }

      .run-button:hover {
        transform: translateY(-1px);
        box-shadow: var(--shadow-lg);
      }

      .run-button:disabled {
        opacity: 0.6;
        cursor: not-allowed;
        transform: none;
      }

      /* Results Section */
      .results-content {
        min-height: 200px; /* Reduced height */
        display: flex;
        flex-direction: column;
        align-items: stretch;
        justify-content: center;
      }

      .placeholder-content {
        text-align: center;
        color: var(--text-tertiary);
        padding: calc(var(--spacing-unit) * 6); /* Reduced padding */
      }

      .placeholder-title {
        font-size: 1.4rem; /* Increased font size */
        color: var(--text-secondary);
        margin-bottom: calc(var(--spacing-unit) * 1);
      }

      .placeholder-text {
        font-size: 1.1rem; /* Increased font size */
        max-width: 400px;
        margin: 0 auto;
      }

      /* Summary Grid */
      .summary-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: calc(var(--spacing-unit) * 3); /* Reduced gap */
        margin-bottom: calc(var(--spacing-unit) * 4); /* Reduced margin */
      }

      .summary-card {
        background-color: var(--bg-subtle);
        border: 1px solid var(--border-color);
        border-radius: var(--radius-lg);
        padding: calc(var(--spacing-unit) * 3); /* Reduced padding */
        text-align: center;
        transition: all 0.2s ease;
      }

      .summary-card:hover {
        transform: translateY(-1px);
        box-shadow: var(--shadow-sm);
      }

      .summary-value {
        display: block;
        font-size: 1.8rem; /* Increased font size */
        font-weight: 700;
        color: var(--text-primary);
        line-height: 1.1;
      }

      .summary-label {
        font-size: 1rem; /* Increased font size */
        color: var(--text-secondary);
        font-weight: 500;
      }

      /* DataTable Styling */
      .dataTables_wrapper {
        font-family: inherit;
        width: 100% !important;
        overflow-x: auto;
        font-size: 1.1rem !important; /* Increased table font size */
      }

      .dataTables_wrapper table {
        font-size: 1.1rem !important; /* Ensure table inherits larger font */
      }

      .dataTables_wrapper th {
        font-size: 1rem !important; /* Increased header font size */
        padding: 8px 6px !important; /* Reduced padding */
      }

      .dataTables_wrapper td {
        font-size: 1.1rem !important; /* Increased cell font size */
        padding: 8px 6px !important; /* Reduced padding */
        line-height: 1.3 !important;
      }

      .dataTables_wrapper .dataTables_length,
      .dataTables_wrapper .dataTables_filter,
      .dataTables_wrapper .dataTables_info,
      .dataTables_wrapper .dataTables_processing,
      .dataTables_wrapper .dataTables_paginate {
        color: var(--text-secondary);
        font-size: 1.1rem !important; /* Increased font size for controls */
      }

      .dataTables_wrapper .dataTables_length select,
      .dataTables_wrapper .dataTables_filter input {
        font-size: 1.1rem !important; /* Increased font size for inputs */
        padding: 4px 6px !important; /* Reduced padding */
      }

      .dataTables_wrapper .dataTables_paginate .paginate_button {
        color: var(--text-secondary) !important;
        border: 1px solid var(--border-color);
        background: var(--bg-card);
        font-size: 1.1rem !important; /* Increased pagination font size */
        padding: 6px 10px !important; /* Reduced padding */
      }

      /* Test Type Badges */
      .test-type-badge {
        display: inline-block;
        padding: 3px 8px; /* Reduced padding */
        border-radius: 12px;
        font-size: 0.8rem; /* Increased font size */
        font-weight: 600;
        white-space: nowrap;
      }
      .test-type-combo {
        background-color: #ebf4ff;
        color: #3b82f6;
      }
      .test-type-drug {
        background-color: #f5f3ff;
        color: #8b5cf6;
      }

      /* Action Buttons */
      .results-actions {
        display: flex;
        justify-content: flex-end;
        gap: calc(var(--spacing-unit) * 3); /* Reduced gap */
        margin-top: calc(var(--spacing-unit) * 4); /* Reduced margin */
        padding-top: calc(var(--spacing-unit) * 4); /* Reduced padding */
        border-top: 1px solid var(--border-color);
      }

      .action-button {
        display: inline-flex;
        align-items: center;
        gap: calc(var(--spacing-unit) * 2);
        padding: calc(var(--spacing-unit) * 2) calc(var(--spacing-unit) * 3); /* Reduced padding */
        border: 1px solid var(--border-color);
        border-radius: var(--radius-md);
        font-size: 1rem; /* Increased font size */
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s ease;
        min-height: 36px; /* Reduced height */
        background-color: var(--bg-card);
        color: var(--text-secondary);
      }

      .action-button:hover:not(:disabled) {
        transform: translateY(-1px);
        box-shadow: var(--shadow-sm);
      }

      .action-button:disabled {
        opacity: 0.5;
        cursor: not-allowed;
        transform: none !important;
        background-color: var(--bg-subtle) !important;
      }

      .action-button.download {
        background-color: var(--atlas-navy);
        color: var(--atlas-white);
        border-color: var(--atlas-navy);
      }

      .action-button.download:hover:not(:disabled) {
        background-color: var(--atlas-navy-light);
        border-color: var(--atlas-navy-light);
      }

      .action-button.save {
        background-color: var(--success-bg);
        color: var(--success-text);
        border-color: var(--success-border);
      }

      .action-button.save:hover:not(:disabled) {
        background-color: #e6fffa;
        border-color: #4fd1c5;
      }

      .action-button.clear {
        background-color: var(--danger-bg);
        color: var(--danger-text);
        border-color: var(--danger-border);
      }

      .action-button.clear:hover:not(:disabled) {
        background-color: #fed7d7;
        border-color: #fc8181;
      }

      /* Loading Spinner */
      .loading-spinner {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        min-height: 200px; /* Reduced height */
        gap: calc(var(--spacing-unit) * 3); /* Reduced gap */
      }

      .spinner {
        width: 40px; /* Reduced size */
        height: 40px; /* Reduced size */
        border: 4px solid var(--bg-subtle);
        border-top-color: var(--atlas-gold);
        border-radius: 50%;
        animation: spin 1s linear infinite;
      }

      @keyframes spin {
        to {
          transform: rotate(360deg);
        }
      }

      .loading-text {
        color: var(--text-secondary);
        font-size: 1.1rem; /* Increased font size */
        font-weight: 500;
      }

      .hidden {
        display: none !important;
      }

      /* Button Container */
      .button-container {
        display: flex;
        justify-content: flex-end;
        margin-top: calc(var(--spacing-unit) * 3); /* Reduced margin */
        padding-top: calc(var(--spacing-unit) * 4); /* Reduced padding */
        border-top: 1px solid var(--border-color);
      }

      /* Responsive Design */
      @media (max-width: 1200px) {
        .kpi-grid {
          grid-template-columns: repeat(2, 1fr);
        }
      }

      @media (max-width: 992px) {
        .header-content {
          flex-direction: column;
          gap: calc(var(--spacing-unit) * 3);
        }
        .form-grid {
          grid-template-columns: 1fr;
        }
      }

      @media (max-width: 768px) {
        .kpi-grid {
          grid-template-columns: 1fr;
        }
        .summary-grid {
          grid-template-columns: 1fr;
        }
        .results-actions {
          flex-direction: column;
          align-items: stretch;
        }
        .action-button {
          justify-content: center;
        }
        .main-content {
          padding: calc(var(--spacing-unit) * 3) calc(var(--spacing-unit) * 4);
        }
        .header-content {
          padding: 0 calc(var(--spacing-unit) * 4);
        }
        body {
          zoom: 1.1; /* Slightly less zoom on mobile */
        }
      }

      /* Placeholder text styling */
      ::placeholder {
        font-size: 1.1rem !important;
        opacity: 0.7;
      }

      .kpi-icon-wrapper {
        width: 36px; /* Reduced size */
        height: 36px; /* Reduced size */
        display: flex;
        align-items: center;
        justify-content: center;
        background-color: var(--bg-subtle);
        border-radius: var(--radius-md);
        font-size: 1.2rem;
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
                  div(class = "nav-tab active", "🏠 Home"),
                  div(class = "nav-tab", "📋 Audit Log"),
                  div(class = "nav-tab", "👥 Employee Management")
              )
          )
      ),
      
      # Main Content
      div(class = "main-content",
          # KPI Section
          div(class = "card",
              h2(class = "section-title", "Key Performance Indicators"),
              div(class = "kpi-grid",
                  div(class = "kpi-card",
                      div(class = "kpi-header",
                          div(class = "kpi-icon-wrapper", "👥"),
                          h3(class = "kpi-title", "Total Active Employees")
                      ),
                      p(class = "kpi-value", "1,247"),
                      div(class = "kpi-footer",
                          span(class = "kpi-subtitle", "Current workforce"),
                          span(class = "kpi-trend up", "+1.2%")
                      )
                  ),
                  div(class = "kpi-card",
                      div(class = "kpi-header",
                          div(class = "kpi-icon-wrapper", "🎯"),
                          h3(class = "kpi-title", "Annual Drug Goal")
                      ),
                      p(class = "kpi-value", "624"),
                      div(class = "kpi-footer",
                          span(class = "kpi-subtitle", "50% of workforce"),
                          div(class = "kpi-progress-bar",
                              div(class = "kpi-progress", style = "width: 50%;")
                          )
                      )
                  ),
                  div(class = "kpi-card",
                      div(class = "kpi-header",
                          div(class = "kpi-icon-wrapper", "🧪"),
                          h3(class = "kpi-title", "Annual Alcohol Goal")
                      ),
                      p(class = "kpi-value", "125"),
                      div(class = "kpi-footer",
                          span(class = "kpi-subtitle", "10% of workforce"),
                          div(class = "kpi-progress-bar",
                              div(class = "kpi-progress", style = "width: 10%;")
                          )
                      )
                  ),
                  div(class = "kpi-card",
                      div(class = "kpi-header",
                          div(class = "kpi-icon-wrapper", "📊"),
                          h3(class = "kpi-title", "Completion Rate")
                      ),
                      p(class = "kpi-value", "87.3%"),
                      div(class = "kpi-footer",
                          span(class = "kpi-subtitle", "YTD Progress"),
                          span(class = "kpi-trend down", "-0.5%")
                      )
                  )
              )
          ),
          
          # Control Panel
          div(class = "card",
              h2(class = "section-title", "Randomizer Configuration"),
              div(class = "form-grid",
                  div(class = "input-group",
                      tags$label("Drug & Alcohol (Combo) Test %", class = "input-label"),
                      numericInput("combo_percent", NULL, value = 25, min = 0, max = 100)
                  ),
                  div(class = "input-group",
                      tags$label("Drug Test %", class = "input-label"),
                      numericInput("drug_percent", NULL, value = 50, min = 0, max = 100)
                  ),
                  div(class = "input-group",
                      tags$label("Quarter", class = "input-label"),
                      selectInput("quarter", NULL,
                                  choices = list(
                                    "Q1 - January to March" = "Q1",
                                    "Q2 - April to June" = "Q2", 
                                    "Q3 - July to September" = "Q3",
                                    "Q4 - October to December" = "Q4"
                                  ),
                                  selected = "Q4")
                  ),
                  div(class = "input-group",
                      tags$label("Year", class = "input-label"),
                      selectInput("year", NULL,
                                  choices = c("2022", "2023", "2024", "2025"),
                                  selected = "2024")
                  )
              ),
              # Button container
              div(class = "button-container",
                  actionButton("run_randomizer", "⚡ Generate Random Selection", class = "run-button")
              )
          ),
          
          # Results Section
          div(class = "card",
              # Loading Spinner (Hidden by default)
              conditionalPanel(
                condition = "input.run_randomizer > 0 && output.results_ready == false && output.run_counter > 0",
                div(class = "loading-spinner",
                    div(class = "spinner"),
                    p(class = "loading-text", "Generating Randomization Results...")
                )
              ),
              
              # Results Content
              conditionalPanel(
                condition = "output.results_ready == true",
                div(
                  h2(class = "section-title", "Random Selection Results"),
                  uiOutput("results_summary"),
                  DT::dataTableOutput("results_table"),
                  # Results actions section
                  div(class = "results-actions",
                      downloadButton("download_results", "📥 Download Results", class = "action-button download"),
                      actionButton("save_results", "💾 Save Results", class = "action-button save"),
                      actionButton("clear_results", "🗑️ Clear Results", class = "action-button clear")
                  )
                )
              ),
              
              # Placeholder Content (Default)
              conditionalPanel(
                condition = "input.run_randomizer == 0",
                div(class = "placeholder-content",
                    div("📋", style = "font-size: 3rem; margin-bottom: calc(var(--spacing-unit) * 3);"),
                    h3(class = "placeholder-title", "Awaiting Configuration"),
                    p(class = "placeholder-text", "Configure and run the randomizer to generate employee selection results.")
                )
              )
          )
      )
  )
)

# Define Server
server <- function(input, output, session) {
  # Reactive values
  results_data <- reactiveVal(NULL)
  results_downloaded <- reactiveVal(FALSE)
  results_saved <- reactiveVal(FALSE)
  
  # Mock audit logs storage (in real app, this would be a database)
  audit_logs <- reactiveVal(data.frame(
    timestamp = as.POSIXct(character(0)),
    user = character(0),
    parameters = character(0),
    stringsAsFactors = FALSE
  ))
  
  # Mock employee data generator
  generate_mock_employees <- function(combo_count, drug_count) {
    first_names <- c("John", "Sarah", "Michael", "Jennifer", "David", "Lisa", "Robert", "Maria", 
                     "James", "Patricia", "William", "Linda", "Richard", "Barbara", "Joseph", "Susan")
    last_names <- c("Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
                    "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson")
    departments <- c("Flight Ops", "Maintenance", "Ground Ops", "Cargo", "Admin", "Safety", "Training")
    positions <- c("Pilot", "Mechanic", "Ground Crew", "Supervisor", "Manager", "Technician", "Coordinator")
    
    employees <- data.frame()
    id_counter <- 1001
    
    # Generate combo test employees
    if (combo_count > 0) {
      combo_employees <- data.frame(
        ID = paste0("AA", id_counter:(id_counter + combo_count - 1)),
        Name = paste(sample(first_names, combo_count, replace = TRUE),
                     sample(last_names, combo_count, replace = TRUE)),
        Department = sample(departments, combo_count, replace = TRUE),
        Position = sample(positions, combo_count, replace = TRUE),
        TestType = "Combo",
        HireDate = as.Date(sample(seq(as.Date("2018-01-01"), as.Date("2023-12-31"), by = "day"), combo_count)),
        stringsAsFactors = FALSE
      )
      employees <- rbind(employees, combo_employees)
      id_counter <- id_counter + combo_count
    }
    
    # Generate drug test employees
    if (drug_count > 0) {
      drug_employees <- data.frame(
        ID = paste0("AA", id_counter:(id_counter + drug_count - 1)),
        Name = paste(sample(first_names, drug_count, replace = TRUE),
                     sample(last_names, drug_count, replace = TRUE)),
        Department = sample(departments, drug_count, replace = TRUE),
        Position = sample(positions, drug_count, replace = TRUE),
        TestType = "Drug",
        HireDate = as.Date(sample(seq(as.Date("2018-01-01"), as.Date("2023-12-31"), by = "day"), drug_count)),
        stringsAsFactors = FALSE
      )
      employees <- rbind(employees, drug_employees)
    }
    
    # Randomize order
    employees[sample(nrow(employees)), ]
  }
  
  # Input validation
  observe({
    combo <- input$combo_percent
    drug <- input$drug_percent
    
    if (!is.null(combo) && !is.null(drug)) {
      if (combo + drug > 100) {
        showNotification("Combined test percentages cannot exceed 100%", type = "error")
        updateNumericInput(session, "combo_percent", value = min(combo, 100 - drug))
      }
    }
  })
  
  # Add a reactive counter for run attempts
  run_counter <- reactiveVal(0)
  
  # Update the run randomizer event
  observeEvent(input$run_randomizer, {
    combo_percent <- input$combo_percent
    drug_percent <- input$drug_percent
    
    # Validation
    if (is.null(combo_percent)) combo_percent <- 0
    if (is.null(drug_percent)) drug_percent <- 0
    
    if (combo_percent + drug_percent > 100) {
      showNotification("Combined test percentages cannot exceed 100%", type = "error")
      return()
    }
    
    if (combo_percent == 0 && drug_percent == 0) {
      showNotification("Please enter at least one test percentage.", type = "error")
      return()
    }
    
    # Increment counter and reset states
    run_counter(run_counter() + 1)
    results_downloaded(FALSE)
    results_saved(FALSE)
    
    # Calculate counts
    total_employees <- 1247
    combo_count <- round((total_employees * combo_percent) / 100)
    drug_count <- round((total_employees * drug_percent) / 100)
    
    # Generate results after delay
    invalidateLater(2000, session)
    
    # Generate mock data
    employees <- generate_mock_employees(combo_count, drug_count)
    results_data(employees)
    
    showNotification("Random selection completed successfully!", type = "message")
  })
  
  # Results ready indicator
  output$results_ready <- reactive({
    !is.null(results_data())
  })
  outputOptions(output, "results_ready", suspendWhenHidden = FALSE)
  
  # Add this output in the server function
  output$run_counter <- reactive({
    run_counter()
  })
  outputOptions(output, "run_counter", suspendWhenHidden = FALSE)
  
  # Results summary
  output$results_summary <- renderUI({
    req(results_data())
    data <- results_data()
    
    combo_count <- sum(data$TestType == "Combo")
    drug_count <- sum(data$TestType == "Drug")
    total_count <- nrow(data)
    
    div(class = "summary-grid",
        div(class = "summary-card",
            span(class = "summary-value", combo_count),
            span(class = "summary-label", "Combo Tests")
        ),
        div(class = "summary-card",
            span(class = "summary-value", drug_count),
            span(class = "summary-label", "Drug Tests")
        ),
        div(class = "summary-card",
            span(class = "summary-value", total_count),
            span(class = "summary-label", "Total Selected")
        )
    )
  })
  
  # Results table
  output$results_table <- DT::renderDataTable({
    req(results_data())
    data <- results_data()
    
    # Format test type with badges
    data$TestType <- sapply(data$TestType, function(test_type) {
      if (test_type == "Combo") {
        paste0('<span class="test-type-badge test-type-combo">Drug & Alcohol</span>')
      } else {
        paste0('<span class="test-type-badge test-type-drug">Drug</span>')
      }
    })
    
    # Format hire date
    data$HireDate <- format(data$HireDate, "%m/%d/%Y")
    
    # Rename columns for display
    names(data) <- c("Employee ID", "Name", "Department", "Position", "Test Type", "Hire Date")
    
    DT::datatable(
      data,
      options = list(
        pageLength = 10,
        lengthMenu = c(10, 25, 50, 100),
        dom = 'Bfrtip',
        scrollX = TRUE,
        columnDefs = list(
          list(className = 'dt-center', targets = 4) # Test Type column
        )
      ),
      escape = FALSE,
      rownames = FALSE
    )
  })
  
  # Download results (Excel format)
  output$download_results <- downloadHandler(
    filename = function() {
      paste("FAA_Randomization_Results_", Sys.Date(), ".xlsx", sep = "")
    },
    content = function(file) {
      req(results_data())
      
      data <- results_data()
      # Clean up test type for Excel
      data$TestType <- ifelse(data$TestType == "Combo", "Drug & Alcohol", "Drug")
      data$HireDate <- format(data$HireDate, "%m/%d/%Y")
      
      # Create workbook and add data
      wb <- createWorkbook()
      addWorksheet(wb, "Randomization Results")
      writeData(wb, "Randomization Results", data)
      
      # Style the header
      headerStyle <- createStyle(
        fontSize = 12,
        fontColour = "#FFFFFF",
        halign = "center",
        fgFill = "#002554",
        border = "TopBottom",
        borderColour = "#000000"
      )
      addStyle(wb, "Randomization Results", headerStyle, rows = 1, cols = 1:ncol(data), gridExpand = TRUE)
      
      # Auto-size columns
      setColWidths(wb, "Randomization Results", cols = 1:ncol(data), widths = "auto")
      
      saveWorkbook(wb, file, overwrite = TRUE)
      
      # Mark as downloaded to enable save button
      results_downloaded(TRUE)
      showNotification("Results downloaded as Excel file! You can now save the audit log.", type = "message")
    }
  )
  
  # Save results (only enabled after download)
  observeEvent(input$save_results, {
    req(results_data())
    
    if (!results_downloaded()) {
      showNotification("Please download the results first before saving.", type = "error")
      return()
    }
    
    # Create audit log entry
    combo_percent <- input$combo_percent %||% 0
    drug_percent <- input$drug_percent %||% 0
    quarter <- input$quarter
    year <- input$year
    
    combo_count <- sum(results_data()$TestType == "Combo")
    drug_count <- sum(results_data()$TestType == "Drug")
    total_count <- nrow(results_data())
    
    parameters <- paste0(
      "Drug: ", drug_percent, "%, ",
      if(combo_percent > 0) paste0("Combo: ", combo_percent, "%, "),
      "Quarter: ", quarter, " ", year, ", ",
      "Total Selected: ", total_count
    )
    
    new_audit <- data.frame(
      timestamp = Sys.time(),
      user = "admin@atlasair.com", # In real app, get from session
      parameters = parameters,
      stringsAsFactors = FALSE
    )
    
    # Add to audit logs
    current_logs <- audit_logs()
    updated_logs <- rbind(new_audit, current_logs)
    audit_logs(updated_logs)
    
    results_saved(TRUE)
    showNotification("Results saved successfully! Audit log has been updated.", type = "message")
  })
  
  # Update save button state based on download status
  observe({
    if (!is.null(results_data())) {
      if (results_downloaded() && !results_saved()) {
        # Enable save button
        runjs("$('#save_results').prop('disabled', false);")
      } else if (results_saved()) {
        # Disable save button after saving
        runjs("$('#save_results').prop('disabled', true);")
      } else {
        # Disable save button if not downloaded
        runjs("$('#save_results').prop('disabled', true);")
      }
    }
  })
  
  # Clear results
  observeEvent(input$clear_results, {
    showModal(modalDialog(
      title = "Clear Results",
      "Are you sure you want to clear the current results? This action cannot be undone.",
      footer = tagList(
        modalButton("Cancel"),
        actionButton("confirm_clear", "Clear Results", class = "btn-danger")
      )
    ))
  })
  
  observeEvent(input$confirm_clear, {
    # Reset all states including the counter
    results_data(NULL)
    results_downloaded(FALSE)
    results_saved(FALSE)
    run_counter(0)  # Reset the counter to stop the spinner
    
    removeModal()
    showNotification("Results cleared successfully! You can now run a new randomization.", type = "message")
  })
}

# Run the application
shinyApp(ui = ui, server = server)
