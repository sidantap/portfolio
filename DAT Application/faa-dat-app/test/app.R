library(shiny)
library(DT)
library(dplyr)
library(shinyjs)
library(lubridate)
library(plotly)
library(htmltools)

# Define UI
ui <- fluidPage(
  # Enable shinyjs
  useShinyjs(),
  
  # Custom CSS for modern, premium design
  tags$head(
    tags$link(href = "https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap", rel = "stylesheet"),
    tags$style(HTML("
      /* Modern Design System */
      :root {
        --atlas-navy: #002554;
        --atlas-navy-light: #003366;
        --atlas-navy-dark: #001a3d;
        --atlas-gold: #f5b400;
        --atlas-gold-light: #ffc933;
        --atlas-gold-dark: #e6a200;
        --atlas-white: #ffffff;
        
        /* Extended Palette */
        --gray-50: #f8fafc;
        --gray-100: #f1f5f9;
        --gray-200: #e2e8f0;
        --gray-300: #cbd5e1;
        --gray-400: #94a3b8;
        --gray-500: #64748b;
        --gray-600: #475569;
        --gray-700: #334155;
        --gray-800: #1e293b;
        --gray-900: #0f172a;
        
        /* Semantic Colors */
        --success: #10b981;
        --success-light: #34d399;
        --warning: #f59e0b;
        --error: #ef4444;
        --info: #3b82f6;
        
        /* Glassmorphism */
        --glass-bg: rgba(255, 255, 255, 0.1);
        --glass-border: rgba(255, 255, 255, 0.2);
        --glass-shadow: 0 8px 32px rgba(0, 37, 84, 0.1);
        
        /* Shadows */
        --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
        --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
        --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        --shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
        --shadow-2xl: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
        
        /* Animations */
        --transition-fast: 150ms cubic-bezier(0.4, 0, 0.2, 1);
        --transition-normal: 300ms cubic-bezier(0.4, 0, 0.2, 1);
        --transition-slow: 500ms cubic-bezier(0.4, 0, 0.2, 1);
        
        /* Spacing */
        --space-1: 0.25rem;
        --space-2: 0.5rem;
        --space-3: 0.75rem;
        --space-4: 1rem;
        --space-5: 1.25rem;
        --space-6: 1.5rem;
        --space-8: 2rem;
        --space-10: 2.5rem;
        --space-12: 3rem;
        --space-16: 4rem;
        --space-20: 5rem;
        
        /* Border Radius */
        --radius-sm: 0.375rem;
        --radius-md: 0.5rem;
        --radius-lg: 0.75rem;
        --radius-xl: 1rem;
        --radius-2xl: 1.5rem;
        --radius-full: 9999px;
      }
      
      /* Reset and Base Styles */
      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }
      
      body {
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
        background: linear-gradient(135deg, var(--gray-50) 0%, var(--gray-100) 100%);
        color: var(--gray-900);
        line-height: 1.6;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
        overflow-x: hidden;
        min-height: 100vh;
      }
      
      .container-fluid {
        padding: 0 !important;
        max-width: 100vw !important;
      }
      
      /* Modern App Layout */
      .app-container {
        display: flex;
        min-height: 100vh;
        background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
        position: relative;
      }
      
      .app-container::before {
        content: '';
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: 
          radial-gradient(circle at 20% 80%, rgba(0, 37, 84, 0.05) 0%, transparent 50%),
          radial-gradient(circle at 80% 20%, rgba(245, 180, 0, 0.05) 0%, transparent 50%);
        pointer-events: none;
        z-index: 0;
      }
      
      /* Sidebar Navigation */
      .sidebar {
        width: 280px;
        background: rgba(255, 255, 255, 0.8);
        backdrop-filter: blur(20px);
        border-right: 1px solid rgba(255, 255, 255, 0.2);
        padding: var(--space-6);
        position: fixed;
        height: 100vh;
        left: 0;
        top: 0;
        z-index: 100;
        transition: transform var(--transition-normal);
        box-shadow: var(--shadow-xl);
      }
      
      .sidebar-header {
        display: flex;
        align-items: center;
        gap: var(--space-3);
        margin-bottom: var(--space-8);
        padding-bottom: var(--space-6);
        border-bottom: 1px solid var(--gray-200);
      }
      
      .logo {
        width: 48px;
        height: 48px;
        background: linear-gradient(135deg, var(--atlas-navy) 0%, var(--atlas-navy-light) 100%);
        border-radius: var(--radius-xl);
        display: flex;
        align-items: center;
        justify-content: center;
        color: var(--atlas-white);
        font-weight: 800;
        font-size: 1.2rem;
        box-shadow: var(--shadow-lg);
        position: relative;
        overflow: hidden;
      }
      
      .logo::before {
        content: '';
        position: absolute;
        top: -50%;
        left: -50%;
        width: 200%;
        height: 200%;
        background: linear-gradient(45deg, transparent, rgba(245, 180, 0, 0.3), transparent);
        transform: rotate(45deg);
        transition: transform var(--transition-slow);
      }
      
      .logo:hover::before {
        transform: rotate(45deg) translate(50%, 50%);
      }
      
      .brand-text {
        flex: 1;
      }
      
      .brand-title {
        font-size: 1.25rem;
        font-weight: 700;
        color: var(--gray-900);
        margin: 0;
      }
      
      .brand-subtitle {
        font-size: 0.875rem;
        color: var(--gray-500);
        margin: 0;
      }
      
      /* Navigation Menu */
      .nav-menu {
        list-style: none;
        padding: 0;
        margin: 0;
      }
      
      .nav-item {
        margin-bottom: var(--space-2);
      }
      
      .nav-link {
        display: flex;
        align-items: center;
        gap: var(--space-3);
        padding: var(--space-3) var(--space-4);
        border-radius: var(--radius-lg);
        color: var(--gray-600);
        text-decoration: none;
        font-weight: 500;
        transition: all var(--transition-fast);
        position: relative;
        overflow: hidden;
        border: none;
        background: none;
        width: 100%;
        cursor: pointer;
        font-size: 0.95rem;
      }
      
      .nav-link::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(245, 180, 0, 0.1), transparent);
        transition: left var(--transition-normal);
      }
      
      .nav-link:hover::before {
        left: 100%;
      }
      
      .nav-link:hover {
        background: rgba(245, 180, 0, 0.05);
        color: var(--atlas-navy);
        transform: translateX(4px);
      }
      
      .nav-link.active {
        background: linear-gradient(135deg, var(--atlas-navy) 0%, var(--atlas-navy-light) 100%);
        color: var(--atlas-white);
        box-shadow: var(--shadow-md);
      }
      
      .nav-link.active:hover {
        transform: translateX(0);
        background: linear-gradient(135deg, var(--atlas-navy-light) 0%, var(--atlas-navy) 100%);
      }
      
      .nav-icon {
        font-size: 1.2rem;
        width: 20px;
        text-align: center;
      }
      
      /* Main Content Area */
      .main-content {
        margin-left: 280px;
        flex: 1;
        padding: var(--space-8);
        position: relative;
        z-index: 1;
        min-height: 100vh;
      }
      
      /* Page Header */
      .page-header {
        margin-bottom: var(--space-8);
        animation: slideInDown 0.6s ease-out;
      }
      
      .page-title {
        font-size: 2.5rem;
        font-weight: 800;
        color: var(--gray-900);
        margin: 0 0 var(--space-2) 0;
        background: linear-gradient(135deg, var(--atlas-navy) 0%, var(--atlas-gold) 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
      }
      
      .page-subtitle {
        font-size: 1.125rem;
        color: var(--gray-600);
        margin: 0;
        font-weight: 400;
      }
      
      /* Glass Cards */
      .glass-card {
        background: rgba(255, 255, 255, 0.7);
        backdrop-filter: blur(20px);
        border: 1px solid rgba(255, 255, 255, 0.3);
        border-radius: var(--radius-2xl);
        padding: var(--space-8);
        margin-bottom: var(--space-6);
        box-shadow: var(--shadow-xl);
        transition: all var(--transition-normal);
        position: relative;
        overflow: hidden;
      }
      
      .glass-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 1px;
        background: linear-gradient(90deg, transparent, rgba(245, 180, 0, 0.5), transparent);
        opacity: 0;
        transition: opacity var(--transition-normal);
      }
      
      .glass-card:hover {
        transform: translateY(-4px);
        box-shadow: var(--shadow-2xl);
        border-color: rgba(245, 180, 0, 0.3);
      }
      
      .glass-card:hover::before {
        opacity: 1;
      }
      
      /* KPI Grid */
      .kpi-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
        gap: var(--space-6);
        margin-bottom: var(--space-8);
      }
      
      .kpi-card {
        background: rgba(255, 255, 255, 0.9);
        backdrop-filter: blur(20px);
        border: 1px solid rgba(255, 255, 255, 0.3);
        border-radius: var(--radius-xl);
        padding: var(--space-6);
        position: relative;
        overflow: hidden;
        transition: all var(--transition-normal);
        cursor: pointer;
      }
      
      .kpi-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: linear-gradient(135deg, transparent 0%, rgba(245, 180, 0, 0.05) 100%);
        opacity: 0;
        transition: opacity var(--transition-normal);
      }
      
      .kpi-card:hover {
        transform: translateY(-8px) scale(1.02);
        box-shadow: var(--shadow-2xl);
        border-color: rgba(245, 180, 0, 0.4);
      }
      
      .kpi-card:hover::before {
        opacity: 1;
      }
      
      .kpi-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: var(--space-4);
      }
      
      .kpi-icon {
        width: 48px;
        height: 48px;
        border-radius: var(--radius-lg);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.5rem;
        background: linear-gradient(135deg, var(--atlas-navy) 0%, var(--atlas-navy-light) 100%);
        color: var(--atlas-white);
        box-shadow: var(--shadow-md);
        position: relative;
        overflow: hidden;
      }
      
      .kpi-icon::after {
        content: '';
        position: absolute;
        top: -50%;
        left: -50%;
        width: 200%;
        height: 200%;
        background: linear-gradient(45deg, transparent, rgba(255, 255, 255, 0.2), transparent);
        transform: rotate(45deg) translate(-100%, -100%);
        transition: transform var(--transition-slow);
      }
      
      .kpi-card:hover .kpi-icon::after {
        transform: rotate(45deg) translate(100%, 100%);
      }
      
      .kpi-trend {
        display: flex;
        align-items: center;
        gap: var(--space-1);
        font-size: 0.875rem;
        font-weight: 600;
        padding: var(--space-1) var(--space-2);
        border-radius: var(--radius-full);
      }
      
      .kpi-trend.up {
        color: var(--success);
        background: rgba(16, 185, 129, 0.1);
      }
      
      .kpi-trend.down {
        color: var(--error);
        background: rgba(239, 68, 68, 0.1);
      }
      
      .kpi-title {
        font-size: 0.875rem;
        font-weight: 600;
        color: var(--gray-600);
        margin: 0 0 var(--space-2) 0;
        text-transform: uppercase;
        letter-spacing: 0.05em;
      }
      
      .kpi-value {
        font-size: 2.5rem;
        font-weight: 800;
        color: var(--gray-900);
        margin: 0 0 var(--space-2) 0;
        line-height: 1;
      }
      
      .kpi-subtitle {
        font-size: 0.875rem;
        color: var(--gray-500);
        margin: 0;
      }
      
      /* Progress Bar */
      .progress-container {
        margin-top: var(--space-4);
      }
      
      .progress-bar {
        width: 100%;
        height: 8px;
        background: var(--gray-200);
        border-radius: var(--radius-full);
        overflow: hidden;
        position: relative;
      }
      
      .progress-fill {
        height: 100%;
        background: linear-gradient(90deg, var(--atlas-gold) 0%, var(--atlas-gold-light) 100%);
        border-radius: var(--radius-full);
        transition: width var(--transition-slow);
        position: relative;
        overflow: hidden;
      }
      
      .progress-fill::after {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
        animation: shimmer 2s infinite;
      }
      
      @keyframes shimmer {
        0% { left: -100%; }
        100% { left: 100%; }
      }
      
      /* Form Controls */
      .form-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: var(--space-6);
        margin-bottom: var(--space-8);
      }
      
      .form-group {
        display: flex;
        flex-direction: column;
        gap: var(--space-2);
      }
      
      .form-label {
        font-size: 0.875rem;
        font-weight: 600;
        color: var(--gray-700);
        margin-bottom: var(--space-1);
      }
      
      .form-control {
        padding: var(--space-3) var(--space-4) !important;
        border: 2px solid var(--gray-200) !important;
        border-radius: var(--radius-lg) !important;
        font-size: 1rem !important;
        font-weight: 500 !important;
        background: rgba(255, 255, 255, 0.8) !important;
        backdrop-filter: blur(10px) !important;
        transition: all var(--transition-fast) !important;
        color: var(--gray-900) !important;
      }
      
      .form-control:focus {
        outline: none !important;
        border-color: var(--atlas-gold) !important;
        box-shadow: 0 0 0 4px rgba(245, 180, 0, 0.1) !important;
        background: var(--atlas-white) !important;
      }
      
      .form-control:hover {
        border-color: var(--gray-300) !important;
      }
      
      /* Slider Control */
      .slider-container {
        position: relative;
        margin: var(--space-4) 0;
      }
      
      .slider-input {
        width: 100%;
        height: 8px;
        border-radius: var(--radius-full);
        background: var(--gray-200);
        outline: none;
        -webkit-appearance: none;
        appearance: none;
      }
      
      .slider-input::-webkit-slider-thumb {
        -webkit-appearance: none;
        appearance: none;
        width: 24px;
        height: 24px;
        border-radius: 50%;
        background: linear-gradient(135deg, var(--atlas-gold) 0%, var(--atlas-gold-light) 100%);
        cursor: pointer;
        box-shadow: var(--shadow-lg);
        transition: all var(--transition-fast);
      }
      
      .slider-input::-webkit-slider-thumb:hover {
        transform: scale(1.2);
        box-shadow: var(--shadow-xl);
      }
      
      .slider-value {
        position: absolute;
        top: -40px;
        left: 50%;
        transform: translateX(-50%);
        background: var(--atlas-navy);
        color: var(--atlas-white);
        padding: var(--space-1) var(--space-2);
        border-radius: var(--radius-md);
        font-size: 0.875rem;
        font-weight: 600;
        opacity: 0;
        transition: opacity var(--transition-fast);
      }
      
      .slider-input:hover + .slider-value,
      .slider-input:focus + .slider-value {
        opacity: 1;
      }
      
      /* Buttons */
      .btn-primary {
        background: linear-gradient(135deg, var(--atlas-navy) 0%, var(--atlas-navy-light) 100%) !important;
        border: none !important;
        color: var(--atlas-white) !important;
        padding: var(--space-3) var(--space-6) !important;
        border-radius: var(--radius-lg) !important;
        font-weight: 600 !important;
        font-size: 1rem !important;
        transition: all var(--transition-fast) !important;
        box-shadow: var(--shadow-md) !important;
        position: relative !important;
        overflow: hidden !important;
        cursor: pointer !important;
      }
      
      .btn-primary::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
        transition: left var(--transition-normal);
      }
      
      .btn-primary:hover {
        transform: translateY(-2px) !important;
        box-shadow: var(--shadow-xl) !important;
        background: linear-gradient(135deg, var(--atlas-navy-light) 0%, var(--atlas-navy) 100%) !important;
      }
      
      .btn-primary:hover::before {
        left: 100%;
      }
      
      .btn-primary:active {
        transform: translateY(0) !important;
      }
      
      .btn-secondary {
        background: rgba(255, 255, 255, 0.8) !important;
        border: 2px solid var(--gray-200) !important;
        color: var(--gray-700) !important;
        padding: var(--space-3) var(--space-6) !important;
        border-radius: var(--radius-lg) !important;
        font-weight: 600 !important;
        font-size: 1rem !important;
        transition: all var(--transition-fast) !important;
        backdrop-filter: blur(10px) !important;
        cursor: pointer !important;
      }
      
      .btn-secondary:hover {
        background: var(--atlas-white) !important;
        border-color: var(--atlas-gold) !important;
        color: var(--atlas-navy) !important;
        transform: translateY(-2px) !important;
        box-shadow: var(--shadow-lg) !important;
      }
      
      .btn-gold {
        background: linear-gradient(135deg, var(--atlas-gold) 0%, var(--atlas-gold-light) 100%) !important;
        border: none !important;
        color: var(--atlas-navy) !important;
        padding: var(--space-3) var(--space-6) !important;
        border-radius: var(--radius-lg) !important;
        font-weight: 700 !important;
        font-size: 1rem !important;
        transition: all var(--transition-fast) !important;
        box-shadow: var(--shadow-md) !important;
        cursor: pointer !important;
      }
      
      .btn-gold:hover {
        transform: translateY(-2px) !important;
        box-shadow: var(--shadow-xl) !important;
        background: linear-gradient(135deg, var(--atlas-gold-light) 0%, var(--atlas-gold) 100%) !important;
      }
      
      /* Loading States */
      .loading-container {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        padding: var(--space-16);
        gap: var(--space-6);
      }
      
      .loading-spinner {
        width: 60px;
        height: 60px;
        border: 4px solid var(--gray-200);
        border-top: 4px solid var(--atlas-gold);
        border-radius: 50%;
        animation: spin 1s linear infinite;
      }
      
      @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
      }
      
      .loading-text {
        font-size: 1.125rem;
        font-weight: 600;
        color: var(--gray-600);
        text-align: center;
      }
      
      .loading-dots {
        display: inline-flex;
        gap: var(--space-1);
      }
      
      .loading-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: var(--atlas-gold);
        animation: bounce 1.4s ease-in-out infinite both;
      }
      
      .loading-dot:nth-child(1) { animation-delay: -0.32s; }
      .loading-dot:nth-child(2) { animation-delay: -0.16s; }
      
      @keyframes bounce {
        0%, 80%, 100% { transform: scale(0); }
        40% { transform: scale(1); }
      }
      
      /* Data Tables */
      .dataTables_wrapper {
        background: rgba(255, 255, 255, 0.8);
        backdrop-filter: blur(20px);
        border-radius: var(--radius-xl);
        padding: var(--space-6);
        border: 1px solid rgba(255, 255, 255, 0.3);
        box-shadow: var(--shadow-lg);
      }
      
      .dataTables_wrapper table {
        border-collapse: separate;
        border-spacing: 0;
        width: 100%;
      }
      
      .dataTables_wrapper th {
        background: linear-gradient(135deg, var(--gray-50) 0%, var(--gray-100) 100%);
        color: var(--gray-700);
        font-weight: 600;
        padding: var(--space-4) var(--space-3);
        border-bottom: 2px solid var(--gray-200);
        font-size: 0.875rem;
        text-transform: uppercase;
        letter-spacing: 0.05em;
      }
      
      .dataTables_wrapper td {
        padding: var(--space-4) var(--space-3);
        border-bottom: 1px solid var(--gray-100);
        font-size: 0.95rem;
        color: var(--gray-800);
      }
      
      .dataTables_wrapper tbody tr {
        transition: all var(--transition-fast);
      }
      
      .dataTables_wrapper tbody tr:hover {
        background: rgba(245, 180, 0, 0.05);
        transform: scale(1.01);
      }
      
      /* Status Badges */
      .status-badge {
        display: inline-flex;
        align-items: center;
        gap: var(--space-1);
        padding: var(--space-1) var(--space-3);
        border-radius: var(--radius-full);
        font-size: 0.875rem;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.025em;
      }
      
      .status-active {
        background: rgba(16, 185, 129, 0.1);
        color: var(--success);
        border: 1px solid rgba(16, 185, 129, 0.2);
      }
      
      .status-loa {
        background: rgba(245, 158, 11, 0.1);
        color: var(--warning);
        border: 1px solid rgba(245, 158, 11, 0.2);
      }
      
      .status-inactive {
        background: rgba(107, 114, 128, 0.1);
        color: var(--gray-600);
        border: 1px solid rgba(107, 114, 128, 0.2);
      }
      
      /* Action Buttons */
      .action-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 36px;
        height: 36px;
        border-radius: var(--radius-lg);
        border: 1px solid var(--gray-200);
        background: rgba(255, 255, 255, 0.8);
        color: var(--gray-600);
        cursor: pointer;
        transition: all var(--transition-fast);
        margin: 0 var(--space-1);
      }
      
      .action-btn:hover {
        background: var(--atlas-white);
        border-color: var(--atlas-gold);
        color: var(--atlas-navy);
        transform: translateY(-2px);
        box-shadow: var(--shadow-md);
      }
      
      .action-btn.danger:hover {
        background: var(--error);
        border-color: var(--error);
        color: var(--atlas-white);
      }
      
      /* Animations */
      @keyframes slideInDown {
        from {
          opacity: 0;
          transform: translateY(-30px);
        }
        to {
          opacity: 1;
          transform: translateY(0);
        }
      }
      
      @keyframes slideInUp {
        from {
          opacity: 0;
          transform: translateY(30px);
        }
        to {
          opacity: 1;
          transform: translateY(0);
        }
      }
      
      @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
      }
      
      .animate-slide-up {
        animation: slideInUp 0.6s ease-out;
      }
      
      .animate-fade-in {
        animation: fadeIn 0.8s ease-out;
      }
      
      /* Responsive Design */
      @media (max-width: 1024px) {
        .sidebar {
          transform: translateX(-100%);
        }
        
        .sidebar.open {
          transform: translateX(0);
        }
        
        .main-content {
          margin-left: 0;
        }
        
        .kpi-grid {
          grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
        }
        
        .form-grid {
          grid-template-columns: 1fr;
        }
      }
      
      @media (max-width: 768px) {
        .main-content {
          padding: var(--space-4);
        }
        
        .page-title {
          font-size: 2rem;
        }
        
        .kpi-grid {
          grid-template-columns: 1fr;
        }
      }
      
      /* Mobile Menu Toggle */
      .mobile-menu-toggle {
        display: none;
        position: fixed;
        top: var(--space-4);
        left: var(--space-4);
        z-index: 200;
        width: 48px;
        height: 48px;
        background: rgba(255, 255, 255, 0.9);
        backdrop-filter: blur(20px);
        border: 1px solid rgba(255, 255, 255, 0.3);
        border-radius: var(--radius-lg);
        cursor: pointer;
        transition: all var(--transition-fast);
      }
      
      @media (max-width: 1024px) {
        .mobile-menu-toggle {
          display: flex;
          align-items: center;
          justify-content: center;
        }
      }
      
      .mobile-menu-toggle:hover {
        background: var(--atlas-white);
        transform: scale(1.05);
      }
      
      /* Hidden class for conditional panels */
      .hidden {
        display: none !important;
      }
      
      /* Custom scrollbar */
      ::-webkit-scrollbar {
        width: 8px;
      }
      
      ::-webkit-scrollbar-track {
        background: var(--gray-100);
        border-radius: var(--radius-full);
      }
      
      ::-webkit-scrollbar-thumb {
        background: var(--gray-300);
        border-radius: var(--radius-full);
      }
      
      ::-webkit-scrollbar-thumb:hover {
        background: var(--atlas-gold);
      }
    "))
  ),
  
  # App Container
  div(class = "app-container",
      # Mobile Menu Toggle
      div(class = "mobile-menu-toggle", id = "mobile-menu-toggle", "☰"),
      
      # Sidebar Navigation
      div(class = "sidebar", id = "sidebar",
          div(class = "sidebar-header",
              div(class = "logo", "AA"),
              div(class = "brand-text",
                  h1(class = "brand-title", "Atlas Air"),
                  p(class = "brand-subtitle", "Testing Portal")
              )
          ),
          
          tags$nav(
            tags$ul(class = "nav-menu",
                    tags$li(class = "nav-item",
                            actionButton("nav_home", 
                                         HTML('<span class="nav-icon">🏠</span><span>Dashboard</span>'),
                                         class = "nav-link active"
                            )
                    ),
                    tags$li(class = "nav-item",
                            actionButton("nav_audit",
                                         HTML('<span class="nav-icon">📋</span><span>Audit Log</span>'),
                                         class = "nav-link"
                            )
                    ),
                    tags$li(class = "nav-item",
                            actionButton("nav_employees",
                                         HTML('<span class="nav-icon">👥</span><span>Employee Management</span>'),
                                         class = "nav-link"
                            )
                    )
            )
          )
          
      ),
      
      # Main Content
      div(class = "main-content",
          # Home Page
          conditionalPanel(
            condition = "output.current_page == 'home'",
            div(class = "page-header",
                h1(class = "page-title", "Dashboard"),
                p(class = "page-subtitle", "Drug and Alcohol Testing Management System")
            ),
            
            # KPI Cards
            div(class = "kpi-grid animate-slide-up",
                div(class = "kpi-card",
                    div(class = "kpi-header",
                        div(class = "kpi-icon", "👥"),
                        div(class = "kpi-trend up", "↗ +1.2%")
                    ),
                    h3(class = "kpi-title", "Active Employees"),
                    p(class = "kpi-value", textOutput("total_employees", inline = TRUE)),
                    p(class = "kpi-subtitle", "Current workforce"),
                    div(class = "progress-container",
                        div(class = "progress-bar",
                            div(class = "progress-fill", style = "width: 85%;")
                        )
                    )
                ),
                
                div(class = "kpi-card",
                    div(class = "kpi-header",
                        div(class = "kpi-icon", "🎯"),
                        div(class = "kpi-trend up", "↗ +2.4%")
                    ),
                    h3(class = "kpi-title", "Drug Testing Goal"),
                    p(class = "kpi-value", textOutput("drug_goal", inline = TRUE)),
                    p(class = "kpi-subtitle", "50% of workforce"),
                    div(class = "progress-container",
                        div(class = "progress-bar",
                            div(class = "progress-fill", style = "width: 50%;")
                        )
                    )
                ),
                
                div(class = "kpi-card",
                    div(class = "kpi-header",
                        div(class = "kpi-icon", "🧪"),
                        div(class = "kpi-trend up", "↗ +0.8%")
                    ),
                    h3(class = "kpi-title", "Alcohol Testing Goal"),
                    p(class = "kpi-value", textOutput("alcohol_goal", inline = TRUE)),
                    p(class = "kpi-subtitle", "10% of workforce"),
                    div(class = "progress-container",
                        div(class = "progress-bar",
                            div(class = "progress-fill", style = "width: 10%;")
                        )
                    )
                ),
                
                div(class = "kpi-card",
                    div(class = "kpi-header",
                        div(class = "kpi-icon", "📊"),
                        div(class = "kpi-trend down", "↘ -0.5%")
                    ),
                    h3(class = "kpi-title", "Completion Rate"),
                    p(class = "kpi-value", "87.3%"),
                    p(class = "kpi-subtitle", "YTD Progress"),
                    div(class = "progress-container",
                        div(class = "progress-bar",
                            div(class = "progress-fill", style = "width: 87.3%;")
                        )
                    )
                )
            ),
            
            # Configuration Panel
            div(class = "glass-card animate-fade-in",
                h2("Randomizer Configuration", style = "font-size: 1.5rem; font-weight: 700; color: var(--gray-900); margin-bottom: var(--space-6);"),
                
                div(class = "form-grid",
                    div(class = "form-group",
                        tags$label(class = "form-label", "Drug & Alcohol (Combo) Test %"),
                        div(class = "slider-container",
                            tags$input(
                              type = "range",
                              id = "combo_percent",
                              class = "slider-input",
                              min = "0",
                              max = "100",
                              value = "25",
                              oninput = "updateSliderValue('combo_percent', this.value)"
                            ),
                            div(class = "slider-value", id = "combo_value", "25%")
                        )
                    ),
                    
                    div(class = "form-group",
                        tags$label(class = "form-label", "Drug Test %"),
                        div(class = "slider-container",
                            tags$input(
                              type = "range",
                              id = "drug_percent",
                              class = "slider-input",
                              min = "0",
                              max = "100",
                              value = "50",
                              oninput = "updateSliderValue('drug_percent', this.value)"
                            ),
                            div(class = "slider-value", id = "drug_value", "50%")
                        )
                    ),
                    
                    div(class = "form-group",
                        tags$label(class = "form-label", "Quarter"),
                        selectInput("quarter", NULL,
                                    choices = list(
                                      "Q1 - January to March" = "Q1",
                                      "Q2 - April to June" = "Q2",
                                      "Q3 - July to September" = "Q3",
                                      "Q4 - October to December" = "Q4"
                                    ),
                                    selected = "Q4"
                        )
                    ),
                    
                    div(class = "form-group",
                        tags$label(class = "form-label", "Year"),
                        selectInput("year", NULL,
                                    choices = c("2022", "2023", "2024", "2025"),
                                    selected = "2024"
                        )
                    )
                ),
                
                div(style = "display: flex; justify-content: flex-end; gap: var(--space-4); margin-top: var(--space-6);",
                    actionButton("clear_config", "Clear"),
                    actionButton("run_randomizer", "⚡ Generate Selection", class = "btn-primary")
                )
            ),
            
            # Results Section
            div(class = "glass-card animate-fade-in",
                conditionalPanel(
                  condition = "input.run_randomizer > 0 && output.results_ready == false",
                  div(class = "loading-container",
                      div(class = "loading-spinner"),
                      div(class = "loading-text", 
                          "Generating randomization results",
                          div(class = "loading-dots",
                              div(class = "loading-dot"),
                              div(class = "loading-dot"),
                              div(class = "loading-dot")
                          )
                      )
                  )
                ),
                
                conditionalPanel(
                  condition = "output.results_ready == true",
                  div(
                    h2("Selection Results", style = "font-size: 1.5rem; font-weight: 700; color: var(--gray-900); margin-bottom: var(--space-6);"),
                    uiOutput("results_summary"),
                    DT::dataTableOutput("results_table"),
                    div(style = "display: flex; justify-content: flex-end; gap: var(--space-4); margin-top: var(--space-6);",
                        downloadButton("download_results", "📥 Download"),
                        actionButton("save_results", "💾 Save", class = "btn-gold"),
                        actionButton("clear_results", "🗑️ Clear")
                    )
                  )
                ),
                
                conditionalPanel(
                  condition = "input.run_randomizer == 0",
                  div(style = "text-align: center; padding: var(--space-16); color: var(--gray-500);",
                      div(style = "font-size: 4rem; margin-bottom: var(--space-4);", "📋"),
                      h3("Ready to Generate", style = "font-size: 1.5rem; font-weight: 600; margin-bottom: var(--space-2);"),
                      p("Configure your testing parameters and click Generate Selection to create randomized employee lists.")
                  )
                )
            )
          ),
          
          # Audit Log Page
          conditionalPanel(
            condition = "output.current_page == 'audit'",
            div(class = "page-header",
                h1(class = "page-title", "Audit Log"),
                p(class = "page-subtitle", "Track all randomizer runs and system activities")
            ),
            
            div(class = "glass-card animate-slide-up",
                h2("Filter Options", style = "font-size: 1.25rem; font-weight: 600; color: var(--gray-900); margin-bottom: var(--space-6);"),
                div(class = "form-grid",
                    div(class = "form-group",
                        tags$label(class = "form-label", "From Date"),
                        dateInput("date_from", NULL, value = NULL)
                    ),
                    div(class = "form-group",
                        tags$label(class = "form-label", "To Date"),
                        dateInput("date_to", NULL, value = NULL)
                    ),
                    div(class = "form-group",
                        tags$label(class = "form-label", "Performed By"),
                        textInput("performed_by", NULL, placeholder = "Enter user email...")
                    )
                )
            ),
            
            div(class = "glass-card animate-fade-in",
                DT::dataTableOutput("audit_table")
            )
          ),
          
          # Employee Management Page
          conditionalPanel(
            condition = "output.current_page == 'employees'",
            div(class = "page-header",
                h1(class = "page-title", "Employee Management"),
                p(class = "page-subtitle", "Manage your employee database and testing pool")
            ),
            
            div(class = "glass-card animate-slide-up",
                div(style = "display: flex; justify-content: space-between; align-items: center; margin-bottom: var(--space-6);",
                    h2("Add New Employee", style = "font-size: 1.25rem; font-weight: 600; color: var(--gray-900); margin: 0;"),
                    div(style = "display: flex; gap: var(--space-3);",
                        fileInput("file_upload", NULL, accept = c(".csv", ".xlsx", ".xls"), 
                                  buttonLabel = "📤 Upload File"),
                        actionButton("show_add_modal", "➕ Add Employee", class = "btn-primary")
                    )
                ),
                
                div(class = "form-grid",
                    div(class = "form-group",
                        tags$label(class = "form-label", "Search"),
                        textInput("search_filter", NULL, placeholder = "Search by ID, name, or occupation...")
                    ),
                    div(class = "form-group",
                        tags$label(class = "form-label", "Filter by Occupation"),
                        selectInput("occupation_filter", NULL,
                                    choices = c("All Occupations" = "all", "Pilot", "Mechanic", "Ground Crew", "Supervisor"),
                                    selected = "all")
                    ),
                    div(class = "form-group",
                        tags$label(class = "form-label", "Filter by Base"),
                        selectInput("base_filter", NULL,
                                    choices = c("All Bases" = "all", "JFK", "MIA", "CVG", "ANC"),
                                    selected = "all")
                    ),
                    div(class = "form-group",
                        tags$label(class = "form-label", "Filter by Status"),
                        div(style = "display: flex; gap: var(--space-2); margin-top: var(--space-2);",
                            actionButton("status_all", "All"),
                            actionButton("status_active", "Active"),
                            actionButton("status_loa", "LOA")
                        )
                    )
                )
            ),
            
            div(class = "glass-card animate-fade-in",
                DT::dataTableOutput("employee_table")
            )
          )
      )
  ),
  
  # JavaScript for interactions
  tags$script(HTML("
    // Slider value updates
    function updateSliderValue(sliderId, value) {
      const valueElement = document.getElementById(sliderId.replace('_percent', '_value'));
      if (valueElement) {
        valueElement.textContent = value + '%';
        valueElement.style.left = value + '%';
      }
      
      // Update Shiny input
      Shiny.setInputValue(sliderId, parseInt(value));
    }
    
    // Mobile menu toggle
    document.getElementById('mobile-menu-toggle').addEventListener('click', function() {
      const sidebar = document.getElementById('sidebar');
      sidebar.classList.toggle('open');
    });
    
    // Close sidebar when clicking outside on mobile
    document.addEventListener('click', function(event) {
      const sidebar = document.getElementById('sidebar');
      const toggle = document.getElementById('mobile-menu-toggle');
      
      if (window.innerWidth <= 1024 && 
          !sidebar.contains(event.target) && 
          !toggle.contains(event.target)) {
        sidebar.classList.remove('open');
      }
    });
    
    // Smooth scrolling for page transitions
    function smoothTransition() {
      document.querySelector('.main-content').style.opacity = '0';
      setTimeout(() => {
        document.querySelector('.main-content').style.opacity = '1';
      }, 150);
    }
    
    // Add loading states to buttons
    document.addEventListener('DOMContentLoaded', function() {
      const buttons = document.querySelectorAll('.btn-primary, .btn-gold');
      buttons.forEach(button => {
        button.addEventListener('click', function() {
          const originalText = this.innerHTML;
          this.innerHTML = '<div class=\"loading-dots\"><div class=\"loading-dot\"></div><div class=\"loading-dot\"></div><div class=\"loading-dot\"></div></div>';
          this.disabled = true;
          
          setTimeout(() => {
            this.innerHTML = originalText;
            this.disabled = false;
          }, 2000);
        });
      });
    });
  "))
)

# Define Server
server <- function(input, output, session) {
  # Navigation state
  current_page <- reactiveVal("home")
  
  # Navigation handlers with smooth transitions
  observeEvent(input$nav_home, {
    current_page("home")
    runjs("
      $('.nav-link').removeClass('active');
      $('#nav_home').addClass('active');
      smoothTransition();
    ")
  })
  
  observeEvent(input$nav_audit, {
    current_page("audit")
    runjs("
      $('.nav-link').removeClass('active');
      $('#nav_audit').addClass('active');
      smoothTransition();
    ")
  })
  
  observeEvent(input$nav_employees, {
    current_page("employees")
    runjs("
      $('.nav-link').removeClass('active');
      $('#nav_employees').addClass('active');
      smoothTransition();
    ")
  })
  
  # Output current page for conditional panels
  output$current_page <- reactive({
    current_page()
  })
  outputOptions(output, "current_page", suspendWhenHidden = FALSE)
  
  # ===== HOME PAGE LOGIC =====
  
  # Reactive values
  results_data <- reactiveVal(NULL)
  results_downloaded <- reactiveVal(FALSE)
  results_saved <- reactiveVal(FALSE)
  
  # Mock employee data
  employees <- reactiveVal(data.frame(
    ID = character(0),
    Name = character(0),
    Occupation = character(0),
    Base = character(0),
    Status = character(0),
    Email = character(0),
    stringsAsFactors = FALSE
  ))
  
  # KPI calculations with smooth animations
  output$total_employees <- renderText({
    emp_data <- employees()
    active_count <- sum(emp_data$Status == "Active", na.rm = TRUE)
    if (active_count == 0) "1,247" else as.character(active_count)
  })
  
  output$drug_goal <- renderText({
    emp_data <- employees()
    active_count <- sum(emp_data$Status == "Active", na.rm = TRUE)
    if (active_count == 0) "624" else as.character(round(active_count * 0.5))
  })
  
  output$alcohol_goal <- renderText({
    emp_data <- employees()
    active_count <- sum(emp_data$Status == "Active", na.rm = TRUE)
    if (active_count == 0) "125" else as.character(round(active_count * 0.1))
  })
  
  # Mock data generator
  generate_mock_employees <- function(combo_count, drug_count) {
    first_names <- c("John", "Sarah", "Michael", "Jennifer", "David", "Lisa", "Robert", "Maria", 
                     "James", "Patricia", "William", "Linda", "Richard", "Barbara", "Joseph", "Susan")
    last_names <- c("Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
                    "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson")
    departments <- c("Flight Ops", "Maintenance", "Ground Ops", "Cargo", "Admin", "Safety", "Training")
    positions <- c("Pilot", "Mechanic", "Ground Crew", "Supervisor", "Manager", "Technician", "Coordinator")
    
    employees_df <- data.frame()
    id_counter <- 1001
    
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
      employees_df <- rbind(employees_df, combo_employees)
      id_counter <- id_counter + combo_count
    }
    
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
      employees_df <- rbind(employees_df, drug_employees)
    }
    
    employees_df[sample(nrow(employees_df)), ]
  }
  
  # Run randomizer with enhanced UX
  observeEvent(input$run_randomizer, {
    combo_percent <- input$combo_percent %||% 0
    drug_percent <- input$drug_percent %||% 0
    
    if (combo_percent + drug_percent > 100) {
      showNotification("Combined test percentages cannot exceed 100%", type = "error")
      return()
    }
    
    if (combo_percent == 0 && drug_percent == 0) {
      showNotification("Please enter at least one test percentage.", type = "error")
      return()
    }
    
    results_downloaded(FALSE)
    results_saved(FALSE)
    
    # Simulate processing time for better UX
    invalidateLater(2500, session)
    
    total_employees <- 1247
    combo_count <- round((total_employees * combo_percent) / 100)
    drug_count <- round((total_employees * drug_percent) / 100)
    
    employees_result <- generate_mock_employees(combo_count, drug_count)
    results_data(employees_result)
    
    showNotification("✨ Random selection completed successfully!", type = "message", duration = 3)
  })
  
  # Results ready indicator
  output$results_ready <- reactive({
    !is.null(results_data())
  })
  outputOptions(output, "results_ready", suspendWhenHidden = FALSE)
  
  # Enhanced results summary with animations
  output$results_summary <- renderUI({
    req(results_data())
    data <- results_data()
    
    combo_count <- sum(data$TestType == "Combo")
    drug_count <- sum(data$TestType == "Drug")
    total_count <- nrow(data)
    
    div(class = "kpi-grid", style = "margin-bottom: var(--space-6);",
        div(class = "kpi-card",
            div(class = "kpi-header",
                div(class = "kpi-icon", "🧪"),
                div(class = "kpi-trend up", "Selected")
            ),
            h3(class = "kpi-title", "Combo Tests"),
            p(class = "kpi-value", combo_count),
            p(class = "kpi-subtitle", "Drug & Alcohol")
        ),
        div(class = "kpi-card",
            div(class = "kpi-header",
                div(class = "kpi-icon", "💊"),
                div(class = "kpi-trend up", "Selected")
            ),
            h3(class = "kpi-title", "Drug Tests"),
            p(class = "kpi-value", drug_count),
            p(class = "kpi-subtitle", "Drug Only")
        ),
        div(class = "kpi-card",
            div(class = "kpi-header",
                div(class = "kpi-icon", "📊"),
                div(class = "kpi-trend up", "Total")
            ),
            h3(class = "kpi-title", "Total Selected"),
            p(class = "kpi-value", total_count),
            p(class = "kpi-subtitle", "Employees")
        )
    )
  })
  
  # Enhanced results table
  output$results_table <- DT::renderDataTable({
    req(results_data())
    data <- results_data()
    
    # Add status badges
    data$TestType <- sapply(data$TestType, function(test_type) {
      if (test_type == "Combo") {
        '<span class="status-badge" style="background: rgba(59, 130, 246, 0.1); color: #3b82f6; border: 1px solid rgba(59, 130, 246, 0.2);">Drug & Alcohol</span>'
      } else {
        '<span class="status-badge" style="background: rgba(139, 92, 246, 0.1); color: #8b5cf6; border: 1px solid rgba(139, 92, 246, 0.2);">Drug Only</span>'
      }
    })
    
    data$HireDate <- format(data$HireDate, "%m/%d/%Y")
    names(data) <- c("Employee ID", "Name", "Department", "Position", "Test Type", "Hire Date")
    
    DT::datatable(
      data,
      options = list(
        pageLength = 10,
        lengthMenu = c(10, 25, 50, 100),
        dom = 'Bfrtip',
        scrollX = TRUE,
        columnDefs = list(
          list(className = 'dt-center', targets = 4)
        )
      ),
      escape = FALSE,
      rownames = FALSE
    )
  })
  
  # ===== AUDIT LOG PAGE LOGIC =====
  
  # Mock audit log data
  audit_logs <- reactiveVal({
    data.frame(
      timestamp = as.POSIXct(c(
        "2025-01-08 10:30:00",
        "2025-01-07 15:45:12",
        "2025-01-06 11:20:35",
        "2025-01-05 09:05:18",
        "2025-01-04 18:00:00",
        "2025-01-03 13:13:13",
        "2025-01-02 16:22:45"
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
  
  # Filtered audit data
  filtered_audit_data <- reactive({
    data <- audit_logs()
    
    if (nrow(data) == 0) return(data)
    
    if (!is.null(input$date_from)) {
      data <- data[as.Date(data$timestamp) >= input$date_from, ]
    }
    
    if (!is.null(input$date_to)) {
      data <- data[as.Date(data$timestamp) <= input$date_to, ]
    }
    
    if (!is.null(input$performed_by) && input$performed_by != "") {
      search_term <- tolower(input$performed_by)
      data <- data[grepl(search_term, tolower(data$user)), ]
    }
    
    return(data)
  })
  
  # Enhanced audit table
  output$audit_table <- DT::renderDataTable({
    data <- filtered_audit_data()
    
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
    
    data$Timestamp <- format(data$timestamp, "%Y-%m-%d %H:%M:%S")
    
    # Add enhanced action buttons
    data$Actions <- paste0(
      '<button class="action-btn" onclick="downloadAuditFile(\'', 
      format(data$timestamp, "%Y-%m-%d"), 
      '\')">📥</button>',
      '<button class="action-btn" onclick="viewAuditDetails(\'', 
      format(data$timestamp, "%Y-%m-%d"), 
      '\')">👁️</button>'
    )
    
    display_data <- data[, c("Timestamp", "user", "parameters", "Actions")]
    names(display_data) <- c("Timestamp", "User", "Parameters", "Actions")
    
    DT::datatable(
      display_data,
      options = list(
        pageLength = 10,
        lengthMenu = c(10, 25, 50, 100),
        dom = 'Bfrtip',
        scrollX = TRUE,
        order = list(list(0, 'desc')),
        columnDefs = list(
          list(className = 'dt-center', targets = 3),
          list(width = '180px', targets = 0),
          list(width = '200px', targets = 1),
          list(width = '100px', targets = 3)
        )
      ),
      escape = FALSE,
      rownames = FALSE
    )
  })
  
  # ===== EMPLOYEE MANAGEMENT PAGE LOGIC =====
  
  # Current status filter
  current_status <- reactiveVal("all")
  
  # Status tab handlers
  observeEvent(input$status_all, {
    current_status("all")
    runjs("
      $('.btn-secondary').removeClass('active');
      $('#status_all').addClass('active');
    ")
  })
  
  observeEvent(input$status_active, {
    current_status("Active")
    runjs("
      $('.btn-secondary').removeClass('active');
      $('#status_active').addClass('active');
    ")
  })
  
  observeEvent(input$status_loa, {
    current_status("LOA")
    runjs("
      $('.btn-secondary').removeClass('active');
      $('#status_loa').addClass('active');
    ")
  })
  
  # File upload with enhanced feedback
  observeEvent(input$file_upload, {
    req(input$file_upload)
    
    ext <- tools::file_ext(input$file_upload$datapath)
    
    tryCatch({
      if (ext == "csv") {
        uploaded_data <- read.csv(input$file_upload$datapath, stringsAsFactors = FALSE)
      } else if (ext %in% c("xlsx", "xls")) {
        uploaded_data <- readxl::read_excel(input$file_upload$datapath)
      } else {
        showNotification("❌ Unsupported file type. Please upload a CSV or XLSX file.", type = "error")
        return()
      }
      
      # Process and validate data
      required_cols <- c("ID", "Name", "Occupation", "Base", "Status")
      if (!all(required_cols %in% names(uploaded_data))) {
        missing_cols <- setdiff(required_cols, names(uploaded_data))
        showNotification(paste("❌ Missing required columns:", paste(missing_cols, collapse = ", ")), type = "error")
        return()
      }
      
      # Add to employee data
      current_data <- employees()
      new_data <- uploaded_data %>%
        filter(!is.na(ID), !is.na(Name)) %>%
        mutate(Email = if("Email" %in% names(uploaded_data)) Email else "")
      
      updated_data <- rbind(current_data, new_data)
      employees(updated_data)
      
      showNotification(paste("✅ Successfully imported", nrow(new_data), "employees"), type = "message")
      
    }, error = function(e) {
      showNotification("❌ Error processing file. Please check the file format.", type = "error")
    })
  })
  
  # Filtered employee data
  filtered_employee_data <- reactive({
    data <- employees()
    
    if (nrow(data) == 0) {
      # Return sample data for demo
      return(data.frame(
        ID = c("AA1001", "AA1002", "AA1003", "AA1004", "AA1005"),
        Name = c("John Smith", "Sarah Johnson", "Michael Brown", "Jennifer Davis", "David Wilson"),
        Occupation = c("Pilot", "Mechanic", "Ground Crew", "Supervisor", "Pilot"),
        Base = c("JFK", "MIA", "CVG", "ANC", "JFK"),
        Status = c("Active", "Active", "LOA", "Active", "Active"),
        Email = c("john.smith@atlasair.com", "sarah.johnson@atlasair.com", "michael.brown@atlasair.com", 
                  "jennifer.davis@atlasair.com", "david.wilson@atlasair.com"),
        stringsAsFactors = FALSE
      ))
    }
    
    # Apply filters
    if (!is.null(input$search_filter) && input$search_filter != "") {
      search_term <- tolower(input$search_filter)
      data <- data[
        grepl(search_term, tolower(data$ID)) |
          grepl(search_term, tolower(data$Name)) |
          grepl(search_term, tolower(data$Occupation)), 
      ]
    }
    
    if (!is.null(input$occupation_filter) && input$occupation_filter != "all") {
      data <- data[data$Occupation == input$occupation_filter, ]
    }
    
    if (!is.null(input$base_filter) && input$base_filter != "all") {
      data <- data[data$Base == input$base_filter, ]
    }
    
    if (current_status() != "all") {
      data <- data[data$Status == current_status(), ]
    }
    
    return(data)
  })
  
  # Enhanced employee table
  output$employee_table <- DT::renderDataTable({
    data <- filtered_employee_data()
    
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
    
    # Add enhanced status badges
    data$Status <- sapply(data$Status, function(status) {
      if (status == "Active") {
        '<span class="status-badge status-active">● Active</span>'
      } else if (status == "LOA") {
        '<span class="status-badge status-loa">● Leave of Absence</span>'
      } else {
        '<span class="status-badge status-inactive">● Inactive</span>'
      }
    })
    
    # Add modern action buttons
    data$Actions <- paste0(
      '<button class="action-btn" onclick="editEmployee(\'', data$ID, '\')">✏️</button>',
      '<button class="action-btn danger" onclick="removeEmployee(\'', data$ID, '\')">🗑️</button>'
    )
    
    DT::datatable(
      data,
      options = list(
        pageLength = 10,
        lengthMenu = c(10, 25, 50, 100),
        dom = 'Bfrtip',
        scrollX = TRUE,
        columnDefs = list(
          list(className = 'dt-center', targets = c(4, 5))
        )
      ),
      escape = FALSE,
      rownames = FALSE
    )
  })
  
  # Clear configuration
  observeEvent(input$clear_config, {
    updateSliderInput(session, "combo_percent", value = 0)
    updateSliderInput(session, "drug_percent", value = 0)
    updateSelectInput(session, "quarter", selected = "Q1")
    updateSelectInput(session, "year", selected = "2024")
    
    runjs("
      document.getElementById('combo_value').textContent = '0%';
      document.getElementById('drug_value').textContent = '0%';
    ")
    
    showNotification("🔄 Configuration cleared", type = "message")
  })
  
  # Clear results
  observeEvent(input$clear_results, {
    results_data(NULL)
    results_downloaded(FALSE)
    results_saved(FALSE)
    showNotification("🗑️ Results cleared", type = "message")
  })
  
  # Download results
  output$download_results <- downloadHandler(
    filename = function() {
      paste("Atlas_Air_Randomization_Results_", Sys.Date(), ".xlsx", sep = "")
    },
    content = function(file) {
      req(results_data())
      
      data <- results_data()
      data$TestType <- ifelse(data$TestType == "Combo", "Drug & Alcohol", "Drug Only")
      data$HireDate <- format(data$HireDate, "%m/%d/%Y")
      
      # Create Excel file (simplified for demo)
      write.csv(data, file, row.names = FALSE)
      
      results_downloaded(TRUE)
      showNotification("📥 Results downloaded successfully!", type = "message")
    }
  )
  
  # Save results
  observeEvent(input$save_results, {
    req(results_data())
    
    # Add to audit log
    new_audit <- data.frame(
      timestamp = Sys.time(),
      user = "admin@atlasair.com",
      parameters = paste0(
        "Drug: ", input$drug_percent %||% 0, "%, ",
        "Combo: ", input$combo_percent %||% 0, "%, ",
        "Quarter: ", input$quarter, " ", input$year,
        ", Total Selected: ", nrow(results_data())
      ),
      stringsAsFactors = FALSE
    )
    
    current_logs <- audit_logs()
    updated_logs <- rbind(new_audit, current_logs)
    audit_logs(updated_logs)
    
    results_saved(TRUE)
    showNotification("💾 Results saved to audit log!", type = "message")
  })
  
  # JavaScript functions for enhanced interactions
  observe({
    runjs("
      window.downloadAuditFile = function(date) {
        const fileName = 'Audit_Log_' + date + '.pdf';
        // Simulate download
        const notification = document.createElement('div');
        notification.textContent = '📥 Downloading: ' + fileName;
        notification.style.cssText = `
          position: fixed;
          top: 20px;
          right: 20px;
          background: var(--atlas-navy);
          color: var(--atlas-white);
          padding: var(--space-3) var(--space-4);
          border-radius: var(--radius-lg);
          box-shadow: var(--shadow-xl);
          z-index: 1000;
          animation: slideInDown 0.3s ease-out;
        `;
        document.body.appendChild(notification);
        setTimeout(() => notification.remove(), 3000);
      };
      
      window.viewAuditDetails = function(date) {
        alert('📋 Viewing audit details for: ' + date);
      };
      
      window.editEmployee = function(employeeId) {
        alert('✏️ Edit functionality for employee ' + employeeId + ' would open a modal here.');
      };
      
      window.removeEmployee = function(employeeId) {
        if (confirm('🗑️ Are you sure you want to remove employee ' + employeeId + '?')) {
          Shiny.setInputValue('remove_employee_id', employeeId, {priority: 'event'});
        }
      };
    ")
  })
}

# Run the application
shinyApp(ui = ui, server = server)
