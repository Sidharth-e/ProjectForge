#!/bin/bash

# ProjectForge - Project Setup Script (Linux/macOS)
# Usage:
#   ./setup.sh                                    # Fully interactive mode - will guide you through all options
#   ./setup.sh -p "MyProject"                    # Interactive mode with pre-set project name
#   ./setup.sh -t "nextjs"                       # Interactive mode with pre-set project type
#   ./setup.sh -t "nextjs" -p "MyApp"            # Direct mode with all parameters
#   ./setup.sh -t "nodejs" -p "MyAPI"            # Direct mode with all parameters
#   ./setup.sh -t "both" -p "MyFullStack"        # Direct mode with all parameters

# Default values
PROJECT_TYPE=""
PROJECT_NAME=""
PROJECT_PATH="."
USE_YARN=false
USE_PNPM=false
USE_TYPESCRIPT=true
USE_SCSS=true
SHOW_HELP=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            PROJECT_TYPE="$2"
            shift 2
            ;;
        -p|--project)
            PROJECT_NAME="$2"
            shift 2
            ;;
        --path)
            PROJECT_PATH="$2"
            shift 2
            ;;
        --yarn)
            USE_YARN=true
            shift
            ;;
        --pnpm)
            USE_PNPM=true
            shift
            ;;
        --no-typescript)
            USE_TYPESCRIPT=false
            shift
            ;;
        --no-scss)
            USE_SCSS=false
            shift
            ;;
        -h|--help)
            SHOW_HELP=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Function to print colored output
print_color() {
    local message="$1"
    local color="$2"
    echo -e "${color}${message}${NC}"
}

# Function to show project type options
show_project_type_options() {
    print_color "" "$WHITE"
    print_color "=== Choose Project Type ===" "$CYAN"
    print_color "1. Next.js (Frontend React Framework)" "$WHITE"
    print_color "2. Node.js (Backend API Server)" "$WHITE"
    print_color "3. Both (Full-stack with Next.js + Node.js)" "$WHITE"
    print_color "" "$WHITE"
    
    while true; do
        read -p "Enter your choice (1, 2, or 3): " choice
        case $choice in
            1) echo "nextjs"; return ;;
            2) echo "nodejs"; return ;;
            3) echo "both"; return ;;
            *) print_color "Invalid choice. Please enter 1, 2, or 3." "$RED" ;;
        esac
    done
}

# Function to get project name
get_project_name() {
    print_color "" "$WHITE"
    print_color "=== Project Name ===" "$CYAN"
    print_color "Enter a name for your project." "$WHITE"
    print_color "Examples: myapp, myapi, myfullstack, blogapp, ecommerceapi" "$WHITE"
    print_color "Note: Project names must be lowercase and contain only letters, numbers, and hyphens." "$YELLOW"
    print_color "" "$WHITE"
    
    while true; do
        read -p "Project name: " name
        if test_project_name "$name"; then
            echo "$name" | tr -d ' '
            return
        fi
    done
}

# Function to test if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to test project name validity
test_project_name() {
    local name="$1"
    
    if [[ -z "$name" ]]; then
        print_color "Project name cannot be empty." "$RED"
        return 1
    fi
    
    # Check for capital letters
    if [[ "$name" =~ [A-Z] ]]; then
        print_color "Project name cannot contain capital letters. Please use lowercase only." "$RED"
        return 1
    fi
    
    # Check for invalid characters
    if [[ ! "$name" =~ ^[a-z0-9-]+$ ]]; then
        print_color "Project name can only contain lowercase letters, numbers, and hyphens." "$RED"
        return 1
    fi
    
    # Check if starts with letter
    if [[ ! "$name" =~ ^[a-z] ]]; then
        print_color "Project name must start with a lowercase letter." "$RED"
        return 1
    fi
    
    # Check if starts or ends with hyphen
    if [[ "$name" =~ ^- ]] || [[ "$name" =~ -$ ]]; then
        print_color "Project name cannot start or end with a hyphen." "$RED"
        return 1
    fi
    
    return 0
}

# Function to test Node.js version
test_node_version() {
    if ! command_exists "node"; then
        print_color "Node.js is not installed. Please install Node.js first." "$RED"
        exit 1
    fi
    
    local node_version=$(node --version)
    print_color "Using Node.js version: $node_version" "$CYAN"
}

# Function to test package manager
test_package_manager() {
    if [[ "$USE_YARN" == true ]] && command_exists "yarn"; then
        echo "yarn"
    elif [[ "$USE_PNPM" == true ]] && command_exists "pnpm"; then
        echo "pnpm"
    elif command_exists "npm"; then
        echo "npm"
    else
        print_color "No package manager found. Installing npm..." "$YELLOW"
        echo "npm"
    fi
}

# Function to create project directory
create_project_directory() {
    local path="$1"
    local name="$2"
    
    local full_path="$path/$name"
    if [[ -d "$full_path" ]]; then
        print_color "Project directory already exists: $full_path" "$YELLOW"
        read -p "Do you want to remove it and create a new one? (y/N): " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            rm -rf "$full_path"
        else
            print_color "Setup cancelled." "$RED"
            exit 1
        fi
    fi
    
    mkdir -p "$full_path"
    echo "$full_path"
}

# Function to cleanup failed project
cleanup_failed_project() {
    local project_path="$1"
    if [[ -d "$project_path" ]]; then
        rm -rf "$project_path"
        print_color "Cleaned up failed project directory: $project_path" "$CYAN"
    fi
}

# Function to setup Next.js project
setup_nextjs_project() {
    local package_manager="$1"
    local use_ts="$2"
    local use_scss="$3"
    
    print_color "Setting up Next.js project..." "$CYAN"
    
    # Create Next.js project with latest version
    local ts_flag=""
    local scss_flag=""
    
    if [[ "$use_ts" == true ]]; then
        ts_flag="--typescript"
    fi
    
    if [[ "$use_scss" == true ]]; then
        scss_flag="--tailwind=false"
    fi
    
    # Create the Next.js app in the current directory
    case "$package_manager" in
        "yarn")
            yarn create next-app@latest . --yes $ts_flag $scss_flag
            ;;
        "pnpm")
            pnpm create next-app@latest . --yes $ts_flag $scss_flag
            ;;
        *)
            npx create-next-app@latest . --yes $ts_flag $scss_flag
            ;;
    esac
    
    # Create additional folder structure
    local folders=(
        "components"
        "components/ui"
        "components/forms"
        "components/layout"
        "hooks"
        "utils"
        "types"
        "constants"
        "services"
        "styles"
        "public/images"
        "public/icons"
    )
    
    for folder in "${folders[@]}"; do
        mkdir -p "$folder"
    done
    
    # Create SCSS files if enabled
    if [[ "$use_scss" == true ]]; then
        local scss_files=(
            "styles/globals.scss"
            "styles/variables.scss"
            "styles/mixins.scss"
            "styles/components.scss"
        )
        
        for file in "${scss_files[@]}"; do
            touch "$file"
        done
        
        # Add basic SCSS content
        cat > "styles/globals.scss" << 'EOF'
@import 'variables';
@import 'mixins';
@import 'components';
EOF
        
        cat > "styles/variables.scss" << 'EOF'
// SCSS Variables

// Colors
$primary-color: #007bff;
$secondary-color: #6c757d;

// Typography
$font-family-base: 'Inter', sans-serif;
$font-size-base: 16px;
EOF
        
        cat > "styles/mixins.scss" << 'EOF'
// SCSS Mixins

@mixin flex-center {
  display: flex;
  align-items: center;
  justify-content: center;
}

@mixin responsive($breakpoint) {
  @media (max-width: $breakpoint) {
    @content;
  }
}
EOF
        
        cat > "styles/components.scss" << 'EOF'
// Component Styles

// Add your component styles here
EOF
    fi
    
    # Create basic component files
    local component_files=(
        "components/layout/Header.tsx"
        "components/layout/Footer.tsx"
        "components/layout/Layout.tsx"
        "components/ui/Button.tsx"
        "components/ui/Card.tsx"
    )
    
    for file in "${component_files[@]}"; do
        touch "$file"
    done
    
    # Create utility files
    local utility_files=(
        "utils/helpers.ts"
        "utils/validation.ts"
        "types/index.ts"
        "constants/config.ts"
    )
    
    for file in "${utility_files[@]}"; do
        touch "$file"
    done
    
    print_color "Next.js project structure created successfully!" "$GREEN"
}

# Function to setup Node.js project
setup_nodejs_project() {
    local package_manager="$1"
    local use_ts="$2"
    
    print_color "Setting up Node.js project..." "$CYAN"
    
    # Initialize package.json
    case "$package_manager" in
        "yarn")
            yarn init -y
            ;;
        "pnpm")
            pnpm init
            ;;
        *)
            npm init -y
            ;;
    esac
    
    # Create folder structure
    local folders=(
        "src"
        "src/controllers"
        "src/models"
        "src/routes"
        "src/middleware"
        "src/services"
        "src/utils"
        "src/types"
        "src/config"
        "tests"
        "tests/unit"
        "tests/integration"
        "docs"
        "logs"
    )
    
    for folder in "${folders[@]}"; do
        mkdir -p "$folder"
    done
    
    # Create basic files
    local files=(
        "src/app.ts"
        "src/server.ts"
        "src/routes/index.ts"
        "src/controllers/index.ts"
        "src/middleware/index.ts"
        "src/config/database.ts"
        "src/config/app.ts"
        "src/types/index.ts"
        "src/utils/logger.ts"
        "tests/setup.ts"
        "docs/README.md"
        ".env.example"
        ".gitignore"
    )
    
    for file in "${files[@]}"; do
        touch "$file"
    done
    
    # Add content to key files
    cat > ".gitignore" << 'EOF'
node_modules/
.env
logs/
*.log
dist/
build/
coverage/
.DS_Store
EOF
    
    cat > ".env.example" << 'EOF'
# Environment Variables
NODE_ENV=development
PORT=3000
DATABASE_URL=mongodb://localhost:27017/your-database
EOF
    
    # Install dependencies
    local dependencies=(
        "express"
        "cors"
        "helmet"
        "morgan"
        "dotenv"
        "winston"
    )
    
    local dev_dependencies=(
        "nodemon"
        "jest"
        "supertest"
        "@types/node"
    )
    
    if [[ "$use_ts" == true ]]; then
        dependencies+=("reflect-metadata")
        dev_dependencies+=(
            "typescript"
            "@types/express"
            "@types/cors"
            "@types/morgan"
            "ts-node"
            "ts-node-dev"
        )
        
        # Create tsconfig.json
        cat > "tsconfig.json" << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
EOF
    fi
    
    # Install dependencies
    case "$package_manager" in
        "yarn")
            yarn add "${dependencies[@]}"
            yarn add -D "${dev_dependencies[@]}"
            ;;
        "pnpm")
            pnpm add "${dependencies[@]}"
            pnpm add -D "${dev_dependencies[@]}"
            ;;
        *)
            npm install "${dependencies[@]}"
            npm install -D "${dev_dependencies[@]}"
            ;;
    esac
    
    # Add scripts to package.json
    if [[ "$use_ts" == true ]]; then
        # Update package.json scripts for TypeScript
        node -e "
        const fs = require('fs');
        const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
        pkg.scripts = {
            'start': 'node dist/server.js',
            'dev': 'ts-node-dev --respawn --transpile-only src/server.ts',
            'build': 'tsc',
            'test': 'jest',
            'test:watch': 'jest --watch',
            'lint': 'eslint src/**/*.ts'
        };
        fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
        "
    else
        # Update package.json scripts for JavaScript
        node -e "
        const fs = require('fs');
        const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
        pkg.scripts = {
            'start': 'node src/server.js',
            'dev': 'nodemon src/server.js',
            'test': 'jest',
            'test:watch': 'jest --watch'
        };
        fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
        "
    fi
    
    print_color "Node.js project structure created successfully!" "$GREEN"
}

# Function to show cleanup help
show_cleanup_help() {
    print_color "" "$WHITE"
    print_color "=== Cleanup Help ===" "$CYAN"
    print_color "If you have failed project directories, you can clean them up:" "$WHITE"
    print_color "1. Remove the failed project folder manually" "$WHITE"
    print_color "2. Run this script again with a valid project name" "$WHITE"
    print_color "" "$WHITE"
    print_color "Valid project names: lowercase letters, numbers, and hyphens only" "$YELLOW"
    print_color "Examples: myapp, myapi, blog-app, ecommerce-api" "$CYAN"
    print_color "" "$WHITE"
}

# Main execution
main() {
    # Show help if requested
    if [[ "$SHOW_HELP" == true ]]; then
        print_color "=== Project Setup Script Help ===" "$CYAN"
        print_color "" "$WHITE"
        print_color "Usage:" "$CYAN"
        print_color "  ./setup.sh                                    # Fully interactive mode" "$WHITE"
        print_color "  ./setup.sh -p 'myapp'                        # Interactive with pre-set name" "$WHITE"
        print_color "  ./setup.sh -t 'nextjs'                       # Interactive with pre-set type" "$WHITE"
        print_color "  ./setup.sh -t 'nextjs' -p 'myapp'" "$WHITE"
        print_color "  ./setup.sh -h                                 # Show this help" "$WHITE"
        print_color "" "$WHITE"
        print_color "Project Types:" "$CYAN"
        print_color "  1. nextjs - Next.js frontend application" "$WHITE"
        print_color "  2. nodejs - Node.js backend API server" "$WHITE"
        print_color "  3. both - Full-stack with Next.js + Node.js" "$WHITE"
        print_color "" "$WHITE"
        print_color "Important: Project names must be lowercase and contain only letters, numbers, and hyphens." "$YELLOW"
        print_color "Examples: myapp, myapi, blog-app, ecommerce-api" "$CYAN"
        print_color "" "$WHITE"
        print_color "Options:" "$CYAN"
        print_color "  --no-typescript    # Disable TypeScript (default: enabled)" "$WHITE"
        print_color "  --no-scss          # Disable SCSS (default: enabled)" "$WHITE"
        print_color "  --yarn             # Use Yarn instead of npm" "$WHITE"
        print_color "  --pnpm             # Use pnpm instead of npm" "$WHITE"
        print_color "" "$WHITE"
        exit 0
    fi
    
    print_color "=== Project Setup Script ===" "$CYAN"
    print_color "This script will help you set up a new project." "$CYAN"
    print_color "You can run it with parameters or interactively." "$CYAN"
    print_color "" "$WHITE"
    print_color "Important: Project names must be lowercase and contain only letters, numbers, and hyphens." "$YELLOW"
    print_color "Examples: myapp, myapi, blog-app, ecommerce-api" "$CYAN"
    print_color "" "$WHITE"
    
    # Check for any existing project directories that might be failed setups
    local existing_projects=()
    if [[ -d "$PROJECT_PATH" ]]; then
        while IFS= read -r -d '' dir; do
            if [[ "$dir" =~ ^[a-z][a-z0-9-]*$ ]]; then
                existing_projects+=("$dir")
            fi
        done < <(find "$PROJECT_PATH" -maxdepth 1 -type d -printf '%f\0' 2>/dev/null)
    fi
    
    if [[ ${#existing_projects[@]} -gt 0 ]]; then
        print_color "Found existing project directories:" "$YELLOW"
        for project in "${existing_projects[@]}"; do
            print_color "  - $project" "$WHITE"
        done
        print_color "" "$WHITE"
        read -p "Do you want to clean up these directories before proceeding? (y/N): " cleanup_response
        if [[ "$cleanup_response" =~ ^[Yy]$ ]]; then
            for project in "${existing_projects[@]}"; do
                local project_path="$PROJECT_PATH/$project"
                print_color "Cleaning up: $project_path" "$CYAN"
                cleanup_failed_project "$project_path"
            done
            print_color "Cleanup completed!" "$GREEN"
        fi
        print_color "" "$WHITE"
    fi
    
    # Validate or get ProjectType
    if [[ -z "$PROJECT_TYPE" ]]; then
        PROJECT_TYPE=$(show_project_type_options)
    else
        # Validate the provided ProjectType
        local valid_types=("nextjs" "nodejs" "both")
        local valid=false
        for type in "${valid_types[@]}"; do
            if [[ "$PROJECT_TYPE" == "$type" ]]; then
                valid=true
                break
            fi
        done
        
        if [[ "$valid" == false ]]; then
            print_color "Invalid ProjectType: '$PROJECT_TYPE'" "$RED"
            print_color "Please choose from the available options:" "$CYAN"
            PROJECT_TYPE=$(show_project_type_options)
        fi
    fi
    
    # Get ProjectName interactively if not provided
    if [[ -z "$PROJECT_NAME" ]]; then
        PROJECT_NAME=$(get_project_name)
    else
        # Validate the provided ProjectName
        if ! test_project_name "$PROJECT_NAME"; then
            PROJECT_NAME=$(get_project_name)
        fi
    fi
    
    print_color "Project Type: $PROJECT_TYPE" "$CYAN"
    print_color "Project Name: $PROJECT_NAME" "$CYAN"
    print_color "Project Path: $PROJECT_PATH" "$CYAN"
    print_color "TypeScript: $USE_TYPESCRIPT" "$CYAN"
    print_color "SCSS: $USE_SCSS" "$CYAN"
    print_color "" "$WHITE"
    
    # Check for existing failed project directories and clean them up
    local potential_failed_path="$PROJECT_PATH/$PROJECT_NAME"
    if [[ -d "$potential_failed_path" ]]; then
        print_color "Found existing project directory: $potential_failed_path" "$YELLOW"
        print_color "This might be from a previous failed setup. Cleaning up..." "$CYAN"
        cleanup_failed_project "$potential_failed_path"
    fi
    
    # Check prerequisites
    test_node_version
    local package_manager=$(test_package_manager)
    print_color "Using package manager: $package_manager" "$CYAN"
    
    # Setup projects based on type
    case "$PROJECT_TYPE" in
        "nextjs")
            # Create project directory for standalone Next.js
            local full_project_path=$(create_project_directory "$PROJECT_PATH" "$PROJECT_NAME")
            print_color "Created project directory: $full_project_path" "$GREEN"
            
            if ! cd "$full_project_path"; then
                print_color "Failed to change to project directory. Cleaning up..." "$RED"
                cleanup_failed_project "$full_project_path"
                exit 1
            fi
            
            setup_nextjs_project "$package_manager" "$USE_TYPESCRIPT" "$USE_SCSS"
            ;;
        "nodejs")
            # Create project directory for standalone Node.js
            local full_project_path=$(create_project_directory "$PROJECT_PATH" "$PROJECT_NAME")
            print_color "Created project directory: $full_project_path" "$GREEN"
            
            if ! cd "$full_project_path"; then
                print_color "Failed to change to project directory. Cleaning up..." "$RED"
                cleanup_failed_project "$full_project_path"
                exit 1
            fi
            
            setup_nodejs_project "$package_manager" "$USE_TYPESCRIPT"
            ;;
        "both")
            # Create both projects in separate directories
            print_color "Setting up both Next.js and Node.js projects..." "$CYAN"
            print_color "Starting from directory: $(pwd)" "$CYAN"
            
            # Step 1: Create the main project directory
            local main_project_path=$(create_project_directory "$PROJECT_PATH" "$PROJECT_NAME")
            print_color "Created main project directory: $main_project_path" "$GREEN"
            
            # Step 2: Create backend and frontend subdirectories
            local backend_path="$main_project_path/backend"
            local frontend_path="$main_project_path/frontend"
            
            # Convert to absolute paths to avoid any relative path issues
            main_project_path=$(realpath "$main_project_path")
            backend_path=$(realpath "$backend_path")
            frontend_path=$(realpath "$frontend_path")
            
            print_color "Main project path (absolute): $main_project_path" "$CYAN"
            print_color "Backend path (absolute): $backend_path" "$CYAN"
            print_color "Frontend path (absolute): $frontend_path" "$CYAN"
            
            mkdir -p "$backend_path"
            mkdir -p "$frontend_path"
            
            print_color "Created backend directory: $backend_path" "$GREEN"
            print_color "Created frontend directory: $frontend_path" "$GREEN"
            
            # Step 3: Setup Node.js backend
            print_color "Setting up Node.js backend..." "$CYAN"
            print_color "Current location before backend setup: $(pwd)" "$CYAN"
            
            # Verify backend path exists before navigating
            if [[ ! -d "$backend_path" ]]; then
                print_color "Backend path does not exist: $backend_path" "$RED"
                cleanup_failed_project "$main_project_path"
                exit 1
            fi
            
            cd "$backend_path"
            print_color "Current location after setting backend: $(pwd)" "$CYAN"
            setup_nodejs_project "$package_manager" "$USE_TYPESCRIPT"
            
            # Step 4: Go back to root, then setup Next.js frontend
            print_color "Going back to main project path: $main_project_path" "$CYAN"
            
            # Verify main project path exists before navigating back
            if [[ ! -d "$main_project_path" ]]; then
                print_color "Main project path does not exist: $main_project_path" "$RED"
                cleanup_failed_project "$main_project_path"
                exit 1
            fi
            
            cd "$main_project_path"
            print_color "Current location after going back to root: $(pwd)" "$CYAN"
            print_color "Setting up Next.js frontend..." "$CYAN"
            
            # Verify frontend path exists before navigating
            if [[ ! -d "$frontend_path" ]]; then
                print_color "Frontend path does not exist: $frontend_path" "$RED"
                cleanup_failed_project "$main_project_path"
                exit 1
            fi
            
            cd "$frontend_path"
            print_color "Current location before frontend setup: $(pwd)" "$CYAN"
            setup_nextjs_project "$package_manager" "$USE_TYPESCRIPT" "$USE_SCSS"
            
            # Step 5: Create root README and go back to root
            print_color "Going back to main project path for README: $main_project_path" "$CYAN"
            
            # Verify main project path exists before final navigation
            if [[ ! -d "$main_project_path" ]]; then
                print_color "Main project path does not exist for README creation: $main_project_path" "$RED"
                cleanup_failed_project "$main_project_path"
                exit 1
            fi
            
            cd "$main_project_path"
            print_color "Current location for README creation: $(pwd)" "$CYAN"
            
            # Final verification that we're in the right place
            local current_location=$(pwd)
            if [[ "$current_location" != "$main_project_path" ]]; then
                print_color "Warning: Current location doesn't match expected main project path" "$YELLOW"
                print_color "Expected: $main_project_path" "$YELLOW"
                print_color "Actual: $current_location" "$YELLOW"
                # Force navigation to the correct path
                cd "$main_project_path"
                print_color "Forced navigation to: $(pwd)" "$CYAN"
            fi
            
            # Create README content
            cat > "README.md" << EOF
# $PROJECT_NAME

This project contains both a Next.js frontend and a Node.js backend.

## Project Structure

- \`frontend/\` - Next.js application
- \`backend/\` - Node.js API server

## Getting Started

### Frontend (Next.js)
\`\`\`bash
cd frontend
$package_manager install
$package_manager dev
\`\`\`

### Backend (Node.js)
\`\`\`bash
cd backend
$package_manager install
$package_manager dev
\`\`\`

## Development

- Frontend runs on: http://localhost:3000
- Backend runs on: http://localhost:3001
EOF
            
            # Set the full project path for the success message
            local full_project_path="$main_project_path"
            ;;
    esac
    
    print_color "" "$WHITE"
    print_color "=== Setup Complete! ===" "$GREEN"
    print_color "Your project has been created successfully at: $full_project_path" "$GREEN"
    
    if [[ "$PROJECT_TYPE" == "both" ]]; then
        print_color "" "$WHITE"
        print_color "Next steps:" "$CYAN"
        print_color "1. cd frontend && $package_manager install && $package_manager dev" "$CYAN"
        print_color "2. cd backend && $package_manager install && $package_manager dev" "$CYAN"
    else
        print_color "" "$WHITE"
        print_color "Next steps:" "$CYAN"
        print_color "1. $package_manager install" "$CYAN"
        print_color "2. $package_manager dev" "$CYAN"
    fi
}

# Error handling
set -e

# Trap errors and cleanup
trap 'print_color "An error occurred. Cleaning up..." "$RED"; exit 1' ERR

# Run main function
main "$@"
