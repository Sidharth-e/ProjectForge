#!/usr/bin/env pwsh

# ProjectForge - Project Setup Script
# Usage:
#   .\setup.ps1                                    # Fully interactive mode - will guide you through all options
#   .\setup.ps1 -ProjectName "MyProject"          # Interactive mode with pre-set project name
#   .\setup.ps1 -ProjectType "nextjs"             # Interactive mode with pre-set project type
#   .\setup.ps1 -ProjectType "nextjs" -ProjectName "MyApp"  # Direct mode with all parameters
#   .\setup.ps1 -ProjectType "nodejs" -ProjectName "MyAPI"  # Direct mode with all parameters
#   .\setup.ps1 -ProjectType "both" -ProjectName "MyFullStack" # Direct mode with all parameters

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectType,
    
    [Parameter(Mandatory=$false)]
    [string]$ProjectName,
    
    [string]$ProjectPath = ".",
    
    [switch]$UseYarn,
    
    [switch]$UsePnpm,
    
    [switch]$UseTypeScript = $true,
    
    [switch]$UseSCSS = $true,
    
    [switch]$Help
)

# Colors for output
$Colors = @{
    Info = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Default = "White"
}

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    
    # Check if the color exists in our colors hashtable, otherwise use White
    if ($Colors.ContainsKey($Color)) {
        Write-Host $Message -ForegroundColor $Colors[$Color]
    } else {
        Write-Host $Message -ForegroundColor "White"
    }
}

function Show-ProjectTypeOptions {
    Write-ColorOutput "" "Default"
    Write-ColorOutput "=== Choose Project Type ===" "Info"
    Write-ColorOutput "1. Next.js (Frontend React Framework)" "Default"
    Write-ColorOutput "2. Node.js (Backend API Server)" "Default"
    Write-ColorOutput "3. Both (Full-stack with Next.js + Node.js)" "Default"
    Write-ColorOutput "" "Default"
    
    do {
        $choice = Read-Host "Enter your choice (1, 2, or 3)"
        switch ($choice) {
            "1" { return "nextjs" }
            "2" { return "nodejs" }
            "3" { return "both" }
            default { 
                Write-ColorOutput "Invalid choice. Please enter 1, 2, or 3." "Error"
            }
        }
    } while ($true)
}

function Get-ProjectName {
    Write-ColorOutput "" "Default"
    Write-ColorOutput "=== Project Name ===" "Info"
    Write-ColorOutput "Enter a name for your project." "Default"
    Write-ColorOutput "Examples: myapp, myapi, myfullstack, blogapp, ecommerceapi" "Default"
    Write-ColorOutput "Note: Project names must be lowercase and contain only letters, numbers, and hyphens." "Warning"
    Write-ColorOutput "" "Default"
    
    do {
        $name = Read-Host "Project name"
        $isValid, $errorMessage = Test-ProjectName -Name $name
        if ($isValid) {
            return $name.Trim()
        } else {
            Write-ColorOutput $errorMessage "Error"
        }
    } while ($true)
}

function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Test-ProjectName {
    param([string]$Name)
    
    if ($Name.Trim() -eq "") {
        return $false, "Project name cannot be empty."
    }
    
    # Check for capital letters using character-by-character comparison
    for ($i = 0; $i -lt $Name.Length; $i++) {
        $char = $Name[$i]
        if ($char -ge 'A' -and $char -le 'Z') {
            return $false, "Project name cannot contain capital letters. Please use lowercase only."
        }
    }
    
    # Check for invalid characters
    for ($i = 0; $i -lt $Name.Length; $i++) {
        $char = $Name[$i]
        if (-not (($char -ge 'a' -and $char -le 'z') -or ($char -ge '0' -and $char -le '9') -or $char -eq '-')) {
            return $false, "Project name can only contain lowercase letters, numbers, and hyphens."
        }
    }
    
    # Check if starts with letter
    if ($Name[0] -lt 'a' -or $Name[0] -gt 'z') {
        return $false, "Project name must start with a lowercase letter."
    }
    
    # Check if starts or ends with hyphen
    if ($Name[0] -eq '-' -or $Name[-1] -eq '-') {
        return $false, "Project name cannot start or end with a hyphen."
    }
    
    return $true, ""
}

function Test-NodeVersion {
    if (-not (Test-Command "node")) {
        Write-ColorOutput "Node.js is not installed. Please install Node.js first." "Error"
        exit 1
    }
    
    $nodeVersion = node --version
    Write-ColorOutput "Using Node.js version: $nodeVersion" "Info"
}

function Test-PackageManager {
    if ($UseYarn -and (Test-Command "yarn")) {
        return "yarn"
    } elseif ($UsePnpm -and (Test-Command "pnpm")) {
        return "pnpm"
    } elseif (Test-Command "npm") {
        return "npm"
    } else {
        Write-ColorOutput "No package manager found. Installing npm..." "Warning"
        return "npm"
    }
}

function Create-ProjectDirectory {
    param([string]$Path, [string]$Name)
    
    $fullPath = Join-Path $Path $Name
    if (Test-Path $fullPath) {
        Write-ColorOutput "Project directory already exists: $fullPath" "Warning"
        $response = Read-Host "Do you want to remove it and create a new one? (y/N)"
        if ($response -eq "y" -or $response -eq "Y") {
            Remove-Item $fullPath -Recurse -Force
        } else {
            Write-ColorOutput "Setup cancelled." "Error"
            exit 1
        }
    }
    
    New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
    return $fullPath
}

function Cleanup-FailedProject {
    param([string]$ProjectPath)
    if (Test-Path $ProjectPath) {
        try {
            Remove-Item $ProjectPath -Recurse -Force
            Write-ColorOutput "Cleaned up failed project directory: $ProjectPath" "Info"
        } catch {
            Write-ColorOutput "Warning: Could not clean up failed project directory: $ProjectPath" "Warning"
        }
    }
}

function Setup-NextJSProject {
    param([string]$PackageManager, [bool]$UseTS, [bool]$UseSCSS)
    
    Write-ColorOutput "Setting up Next.js project..." "Info"
    
    # Create Next.js project with latest version
    $tsFlag = if ($UseTS) { "--typescript" } else { "" }
    $scssFlag = if ($UseSCSS) { "--tailwind=false" } else { "" }
    
    # Create the Next.js app in the current directory
    if ($PackageManager -eq "yarn") {
        yarn create next-app@latest . --yes $tsFlag $scssFlag
    } elseif ($PackageManager -eq "pnpm") {
        pnpm create next-app@latest . --yes $tsFlag $scssFlag
    } else {
        npx create-next-app@latest . --yes $tsFlag $scssFlag
    }
    
    # Create additional folder structure
    $folders = @(
        "components",
        "components/ui",
        "components/forms",
        "components/layout",
        "hooks",
        "utils",
        "types",
        "constants",
        "services",
        "styles",
        "public/images",
        "public/icons"
    )
    
    foreach ($folder in $folders) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
    }
    
    # Create SCSS files if enabled
    if ($UseSCSS) {
        $scssFiles = @(
            "styles/globals.scss",
            "styles/variables.scss",
            "styles/mixins.scss",
            "styles/components.scss"
        )
        
        foreach ($file in $scssFiles) {
            New-Item -ItemType File -Path $file -Force | Out-Null
        }
        
        # Add basic SCSS content
        Set-Content "styles/globals.scss" "@import 'variables';`n@import 'mixins';`n@import 'components';"
        Set-Content "styles/variables.scss" "// SCSS Variables`n`n// Colors`n`$primary-color: #007bff;`n`$secondary-color: #6c757d;`n`n// Typography`n`$font-family-base: 'Inter', sans-serif;`n`$font-size-base: 16px;"
        Set-Content "styles/mixins.scss" "// SCSS Mixins`n`n@mixin flex-center {`n  display: flex;`n  align-items: center;`n  justify-content: center;`n}`n`n@mixin responsive(`$breakpoint) {`n  @media (max-width: `$breakpoint) {`n    @content;`n  }`n}"
        Set-Content "styles/components.scss" "// Component Styles`n`n// Add your component styles here"
    }
    
    # Create basic component files
    $componentFiles = @(
        "components/layout/Header.tsx",
        "components/layout/Footer.tsx",
        "components/layout/Layout.tsx",
        "components/ui/Button.tsx",
        "components/ui/Card.tsx"
    )
    
    foreach ($file in $componentFiles) {
        New-Item -ItemType File -Path $file -Force | Out-Null
    }
    
    # Create utility files
    $utilityFiles = @(
        "utils/helpers.ts",
        "utils/validation.ts",
        "types/index.ts",
        "constants/config.ts"
    )
    
    foreach ($file in $utilityFiles) {
        New-Item -ItemType File -Path $file -Force | Out-Null
    }
    
    Write-ColorOutput "Next.js project structure created successfully!" "Success"
}

function Setup-NodeJSProject {
    param([string]$PackageManager, [bool]$UseTS)
    
    Write-ColorOutput "Setting up Node.js project..." "Info"
    
    # Initialize package.json
    if ($PackageManager -eq "yarn") {
        yarn init -y
    } elseif ($PackageManager -eq "pnpm") {
        pnpm init
    } else {
        npm init -y
    }
    
    # Create folder structure
    $folders = @(
        "src",
        "src/controllers",
        "src/models",
        "src/routes",
        "src/middleware",
        "src/services",
        "src/utils",
        "src/types",
        "src/config",
        "tests",
        "tests/unit",
        "tests/integration",
        "docs",
        "logs"
    )
    
    foreach ($folder in $folders) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
    }
    
    # Create basic files
    $files = @(
        "src/app.ts",
        "src/server.ts",
        "src/routes/index.ts",
        "src/controllers/index.ts",
        "src/middleware/index.ts",
        "src/config/database.ts",
        "src/config/app.ts",
        "src/types/index.ts",
        "src/utils/logger.ts",
        "tests/setup.ts",
        "docs/README.md",
        ".env.example",
        ".gitignore"
    )
    
    foreach ($file in $files) {
        New-Item -ItemType File -Path $file -Force | Out-Null
    }
    
    # Add content to key files
    Set-Content ".gitignore" "node_modules/`n.env`nlogs/`n*.log`ndist/`nbuild/`ncoverage/`n.DS_Store"
    Set-Content ".env.example" "# Environment Variables`nNODE_ENV=development`nPORT=3000`nDATABASE_URL=mongodb://localhost:27017/your-database"
    
    # Install dependencies
    $dependencies = @(
        "express",
        "cors",
        "helmet",
        "morgan",
        "dotenv",
        "winston"
    )
    
    $devDependencies = @(
        "nodemon",
        "jest",
        "supertest",
        "@types/node"
    )
    
    if ($UseTS) {
        $dependencies += @("reflect-metadata")
        $devDependencies += @(
            "typescript",
            "@types/express",
            "@types/cors",
            "@types/morgan",
            "ts-node",
            "ts-node-dev"
        )
        
        # Create tsconfig.json
        $tsConfig = @{
            compilerOptions = @{
                target = "ES2020"
                module = "commonjs"
                lib = @("ES2020")
                outDir = "./dist"
                rootDir = "./src"
                strict = $true
                esModuleInterop = $true
                skipLibCheck = $true
                forceConsistentCasingInFileNames = $true
                resolveJsonModule = $true
                experimentalDecorators = $true
                emitDecoratorMetadata = $true
            }
            include = @("src/**/*")
            exclude = @("node_modules", "dist", "tests")
        }
        
        $tsConfig | ConvertTo-Json -Depth 10 | Set-Content "tsconfig.json"
    }
    
    # Install dependencies
    if ($PackageManager -eq "yarn") {
        yarn add $dependencies
        yarn add -D $devDependencies
    } elseif ($PackageManager -eq "pnpm") {
        pnpm add $dependencies
        pnpm add -D $devDependencies
    } else {
        npm install $dependencies
        npm install -D $devDependencies
    }
    
    # Add scripts to package.json
    $packageJson = Get-Content "package.json" | ConvertFrom-Json
    
    if ($UseTS) {
        $packageJson.scripts = @{
            "start" = "node dist/server.js"
            "dev" = "ts-node-dev --respawn --transpile-only src/server.ts"
            "build" = "tsc"
            "test" = "jest"
            "test:watch" = "jest --watch"
            "lint" = "eslint src/**/*.ts"
        }
    } else {
        $packageJson.scripts = @{
            "start" = "node src/server.js"
            "dev" = "nodemon src/server.js"
            "test" = "jest"
            "test:watch" = "jest --watch"
        }
    }
    
    $packageJson | ConvertTo-Json -Depth 10 | Set-Content "package.json"
    
    Write-ColorOutput "Node.js project structure created successfully!" "Success"
}

# Function to help users clean up failed projects
function Show-CleanupHelp {
    Write-ColorOutput "" "Default"
    Write-ColorOutput "=== Cleanup Help ===" "Info"
    Write-ColorOutput "If you have failed project directories, you can clean them up:" "Default"
    Write-ColorOutput "1. Remove the failed project folder manually" "Default"
    Write-ColorOutput "2. Run this script again with a valid project name" "Default"
    Write-ColorOutput "" "Default"
    Write-ColorOutput "Valid project names: lowercase letters, numbers, and hyphens only" "Warning"
    Write-ColorOutput "Examples: myapp, myapi, blog-app, ecommerce-api" "Info"
    Write-ColorOutput "" "Default"
}

# Main execution
try {
    # Show help if requested
    if ($Help) {
        Write-ColorOutput "=== Project Setup Script Help ===" "Info"
        Write-ColorOutput "" "Default"
        Write-ColorOutput "Usage:" "Info"
        Write-ColorOutput "  .\setup.ps1                                    # Fully interactive mode" "Default"
        Write-ColorOutput "  .\setup.ps1 -ProjectName 'myapp'              # Interactive with pre-set name" "Default"
        Write-ColorOutput "  .\setup.ps1 -ProjectType 'nextjs'             # Interactive with pre-set type" "Default"
        Write-ColorOutput "  .\setup.ps1 -ProjectType 'nextjs' -ProjectName 'myapp'" "Default"
        Write-ColorOutput "  .\setup.ps1 -Help                             # Show this help" "Default"
        Write-ColorOutput "" "Default"
        Write-ColorOutput "Project Types:" "Info"
        Write-ColorOutput "  1. nextjs - Next.js frontend application" "Default"
        Write-ColorOutput "  2. nodejs - Node.js backend API server" "Default"
        Write-ColorOutput "  3. both - Full-stack with Next.js + Node.js" "Default"
        Write-ColorOutput "" "Default"
        Write-ColorOutput "Important: Project names must be lowercase and contain only letters, numbers, and hyphens." "Warning"
        Write-ColorOutput "Examples: myapp, myapi, blog-app, ecommerce-api" "Info"
        Write-ColorOutput "" "Default"
        Write-ColorOutput "Options:" "Info"
        Write-ColorOutput "  -UseTypeScript    # Enable TypeScript (default: true)" "Default"
        Write-ColorOutput "  -UseSCSS          # Enable SCSS (default: true)" "Default"
        Write-ColorOutput "  -UseYarn          # Use Yarn instead of npm" "Default"
        Write-ColorOutput "  -UsePnpm          # Use pnpm instead of npm" "Default"
        Write-ColorOutput "" "Default"
        exit 0
    }
    
    Write-ColorOutput "=== Project Setup Script ===" "Info"
    Write-ColorOutput "This script will help you set up a new project." "Info"
    Write-ColorOutput "You can run it with parameters or interactively." "Info"
    Write-ColorOutput "" "Default"
    Write-ColorOutput "Important: Project names must be lowercase and contain only letters, numbers, and hyphens." "Warning"
    Write-ColorOutput "Examples: myapp, myapi, blog-app, ecommerce-api" "Info"
    Write-ColorOutput "" "Default"
    
    # Check for any existing project directories that might be failed setups
    $existingProjects = Get-ChildItem -Path $ProjectPath -Directory -Name | Where-Object { $_ -match '^[a-z][a-z0-9-]*$' }
    if ($existingProjects) {
        Write-ColorOutput "Found existing project directories:" "Warning"
        foreach ($project in $existingProjects) {
            Write-ColorOutput "  - $project" "Default"
        }
        Write-ColorOutput "" "Default"
        $cleanupResponse = Read-Host "Do you want to clean up these directories before proceeding? (y/N)"
        if ($cleanupResponse -eq "y" -or $cleanupResponse -eq "Y") {
            foreach ($project in $existingProjects) {
                $projectPath = Join-Path $ProjectPath $project
                Write-ColorOutput "Cleaning up: $projectPath" "Info"
                Cleanup-FailedProject -ProjectPath $projectPath
            }
            Write-ColorOutput "Cleanup completed!" "Success"
        }
        Write-ColorOutput "" "Default"
    }
    
    # Validate or get ProjectType
    if (-not $ProjectType) {
        $ProjectType = Show-ProjectTypeOptions
    } else {
        # Validate the provided ProjectType
        $validTypes = @("nextjs", "nodejs", "both")
        if ($ProjectType -notin $validTypes) {
            Write-ColorOutput "Invalid ProjectType: '$ProjectType'" "Error"
            Write-ColorOutput "Please choose from the available options:" "Info"
            $ProjectType = Show-ProjectTypeOptions
        }
    }
    
    # Get ProjectName interactively if not provided
    if (-not $ProjectName) {
        $ProjectName = Get-ProjectName
    } else {
        # Validate the provided ProjectName
        $isValid, $errorMessage = Test-ProjectName -Name $ProjectName
        if (-not $isValid) {
            Write-ColorOutput "Invalid ProjectName: $errorMessage" "Error"
            $ProjectName = Get-ProjectName
        }
    }
    
    Write-ColorOutput "Project Type: $ProjectType" "Info"
    Write-ColorOutput "Project Name: $ProjectName" "Info"
    Write-ColorOutput "Project Path: $ProjectPath" "Info"
    Write-ColorOutput "TypeScript: $UseTypeScript" "Info"
    Write-ColorOutput "SCSS: $UseSCSS" "Info"
    Write-ColorOutput "" "Default"
    
    # Check for existing failed project directories and clean them up
    $potentialFailedPath = Join-Path $ProjectPath $ProjectName
    if (Test-Path $potentialFailedPath) {
        Write-ColorOutput "Found existing project directory: $potentialFailedPath" "Warning"
        Write-ColorOutput "This might be from a previous failed setup. Cleaning up..." "Info"
        Cleanup-FailedProject -ProjectPath $potentialFailedPath
    }
    
    # Check prerequisites
    Test-NodeVersion
    $packageManager = Test-PackageManager
    Write-ColorOutput "Using package manager: $packageManager" "Info"
    
    # Setup projects based on type
    switch ($ProjectType) {
        "nextjs" {
            # Create project directory for standalone Next.js
            $fullProjectPath = Create-ProjectDirectory -Path $ProjectPath -Name $ProjectName
            Write-ColorOutput "Created project directory: $fullProjectPath" "Success"
            
            try {
                Set-Location $fullProjectPath
                Setup-NextJSProject -PackageManager $packageManager -UseTS $UseTypeScript -UseSCSS $UseSCSS
            } catch {
                Write-ColorOutput "Failed to setup Next.js project. Cleaning up..." "Error"
                Cleanup-FailedProject -ProjectPath $fullProjectPath
                throw
            }
        }
        "nodejs" {
            # Create project directory for standalone Node.js
            $fullProjectPath = Create-ProjectDirectory -Path $ProjectPath -Name $ProjectName
            Write-ColorOutput "Created project directory: $fullProjectPath" "Success"
            
            try {
                Set-Location $fullProjectPath
                Setup-NodeJSProject -PackageManager $packageManager -UseTS $UseTypeScript
            } catch {
                Write-ColorOutput "Failed to setup Node.js project. Cleaning up..." "Error"
                Cleanup-FailedProject -ProjectPath $fullProjectPath
                throw
            }
        }
        "both" {
            # Create both projects in separate directories
            Write-ColorOutput "Setting up both Next.js and Node.js projects..." "Info"
            Write-ColorOutput "Starting from directory: $(Get-Location)" "Info"
            
            # Step 1: Create the main project directory
            $mainProjectPath = Create-ProjectDirectory -Path $ProjectPath -Name $ProjectName
            Write-ColorOutput "Created main project directory: $mainProjectPath" "Success"
            
            try {
                # Step 2: Create backend and frontend subdirectories
                $backendPath = Join-Path $mainProjectPath "backend"
                $frontendPath = Join-Path $mainProjectPath "frontend"
                
                # Convert to absolute paths to avoid any relative path issues
                $mainProjectPath = [System.IO.Path]::GetFullPath($mainProjectPath)
                $backendPath = [System.IO.Path]::GetFullPath($backendPath)
                $frontendPath = [System.IO.Path]::GetFullPath($frontendPath)
                
                Write-ColorOutput "Main project path (absolute): $mainProjectPath" "Info"
                Write-ColorOutput "Backend path (absolute): $backendPath" "Info"
                Write-ColorOutput "Frontend path (absolute): $frontendPath" "Info"
                
                New-Item -ItemType Directory -Path $backendPath -Force | Out-Null
                New-Item -ItemType Directory -Path $frontendPath -Force | Out-Null
                
                Write-ColorOutput "Created backend directory: $backendPath" "Success"
                Write-ColorOutput "Created frontend directory: $frontendPath" "Success"
                
                # Step 3: Setup Node.js backend
                Write-ColorOutput "Setting up Node.js backend..." "Info"
                Write-ColorOutput "Current location before backend setup: $(Get-Location)" "Info"
                
                # Verify backend path exists before navigating
                if (-not (Test-Path $backendPath)) {
                    throw "Backend path does not exist: $backendPath"
                }
                
                Set-Location $backendPath
                Write-ColorOutput "Current location after setting backend: $(Get-Location)" "Info"
                Setup-NodeJSProject -PackageManager $packageManager -UseTS $UseTypeScript
                
                # Step 4: Go back to root, then setup Next.js frontend
                Write-ColorOutput "Going back to main project path: $mainProjectPath" "Info"
                
                # Verify main project path exists before navigating back
                if (-not (Test-Path $mainProjectPath)) {
                    throw "Main project path does not exist: $mainProjectPath"
                }
                
                Set-Location $mainProjectPath
                Write-ColorOutput "Current location after going back to root: $(Get-Location)" "Info"
                Write-ColorOutput "Setting up Next.js frontend..." "Info"
                
                # Verify frontend path exists before navigating
                if (-not (Test-Path $frontendPath)) {
                    throw "Frontend path does not exist: $frontendPath"
                }
                
                Set-Location $frontendPath
                Write-ColorOutput "Current location before frontend setup: $(Get-Location)" "Info"
                Setup-NextJSProject -PackageManager $packageManager -UseTS $UseTypeScript -UseSCSS $UseSCSS
                
                # Step 5: Create root README and go back to root
                Write-ColorOutput "Going back to main project path for README: $mainProjectPath" "Info"
                
                # Verify main project path exists before final navigation
                if (-not (Test-Path $mainProjectPath)) {
                    throw "Main project path does not exist for README creation: $mainProjectPath"
                }
                
                Set-Location $mainProjectPath
                Write-ColorOutput "Current location for README creation: $(Get-Location)" "Info"
                
                # Final verification that we're in the right place
                $currentLocation = Get-Location
                if ($currentLocation.Path -ne $mainProjectPath) {
                    Write-ColorOutput "Warning: Current location doesn't match expected main project path" "Warning"
                    Write-ColorOutput "Expected: $mainProjectPath" "Warning"
                    Write-ColorOutput "Actual: $($currentLocation.Path)" "Warning"
                    # Force navigation to the correct path
                    Set-Location $mainProjectPath
                    Write-ColorOutput "Forced navigation to: $(Get-Location)" "Info"
                }
                
                $readmeContent = @"
# $ProjectName

This project contains both a Next.js frontend and a Node.js backend.

## Project Structure

- \`frontend/\` - Next.js application
- \`backend/\` - Node.js API server

## Getting Started

### Frontend (Next.js)
\`\`\`bash
cd frontend
$packageManager install
$packageManager dev
\`\`\`

### Backend (Node.js)
\`\`\`bash
cd backend
$packageManager install
$packageManager dev
\`\`\`

## Development

- Frontend runs on: http://localhost:3000
- Backend runs on: http://localhost:3001
"@
                Set-Content "README.md" $readmeContent
                
                # Set the full project path for the success message
                $fullProjectPath = $mainProjectPath
            } catch {
                Write-ColorOutput "Failed to setup projects. Cleaning up..." "Error"
                Cleanup-FailedProject -ProjectPath $mainProjectPath
                throw
            }
        }
    }
    
    Write-ColorOutput "" "Default"
    Write-ColorOutput "=== Setup Complete! ===" "Success"
    Write-ColorOutput "Your project has been created successfully at: $fullProjectPath" "Success"
    
    if ($ProjectType -eq "both") {
        Write-ColorOutput "" "Default"
        Write-ColorOutput "Next steps:" "Info"
        Write-ColorOutput "1. cd frontend && $packageManager install && $packageManager dev" "Info"
        Write-ColorOutput "2. cd backend && $packageManager install && $packageManager dev" "Info"
    } else {
        Write-ColorOutput "" "Default"
        Write-ColorOutput "Next steps:" "Info"
        Write-ColorOutput "1. $packageManager install" "Info"
        Write-ColorOutput "2. $packageManager dev" "Info"
    }
    
} catch {
    Write-ColorOutput "An error occurred: $($_.Exception.Message)" "Error"
    Write-ColorOutput "" "Default"
    Write-ColorOutput "If you have any failed project directories, you can clean them up manually:" "Info"
    Write-ColorOutput "1. Remove the failed project folder" "Info"
    Write-ColorOutput "2. Run the script again with a valid project name" "Info"
    Write-ColorOutput "" "Default"
    Write-ColorOutput "Valid project names: lowercase letters, numbers, and hyphens only" "Warning"
    Write-ColorOutput "Examples: myapp, myapi, blog-app, ecommerce-api" "Info"
    exit 1
}
