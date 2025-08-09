# ProjectForge

A powerful project setup automation tool that creates Next.js frontend, Node.js backend, or full-stack projects with a single command.

## 🚀 Features

- **Multiple Project Types**: Create Next.js, Node.js, or full-stack projects
- **Smart Project Structure**: Automatically generates organized folder structures
- **TypeScript Support**: Built-in TypeScript configuration (enabled by default)
- **SCSS Support**: Modern SCSS setup with variables, mixins, and component styles
- **Package Manager Flexibility**: Support for npm, Yarn, and pnpm
- **Interactive & Direct Modes**: Run interactively or with command-line parameters
- **Cross-Platform**: Available for both Windows (PowerShell) and Linux/macOS (Bash)
- **Error Handling**: Robust error handling with automatic cleanup on failures

## 📋 Prerequisites

- **Node.js** (version 14 or higher)
- **npm** (comes with Node.js)
- **Optional**: Yarn or pnpm for alternative package management

## 🛠️ Installation

1. Clone or download this repository
2. Navigate to the ProjectForge directory
3. Choose your platform:

### Windows (PowerShell)
```powershell
# Make sure PowerShell execution policy allows running scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run the setup script
.\setup.ps1
```

### Linux/macOS (Bash)
```bash
# Make the script executable
chmod +x setup.sh

# Run the setup script
./setup.sh
```

## 📖 Usage

### Interactive Mode (Recommended for first-time users)
```bash
# Windows
.\setup.ps1

# Linux/macOS
./setup.sh
```

### Direct Mode with Parameters
```bash
# Windows
.\setup.ps1 -ProjectType "nextjs" -ProjectName "myapp"

# Linux/macOS
./setup.sh -t "nextjs" -p "myapp"
```

### Command Line Options

| Option | PowerShell | Bash | Description |
|--------|------------|------|-------------|
| Project Type | `-ProjectType` | `-t, --type` | Project type: `nextjs`, `nodejs`, or `both` |
| Project Name | `-ProjectName` | `-p, --project` | Name for your project |
| Project Path | `-ProjectPath` | `--path` | Directory to create project in (default: current) |
| Use Yarn | `-UseYarn` | `--yarn` | Use Yarn instead of npm |
| Use pnpm | `-UsePnpm` | `--pnpm` | Use pnpm instead of npm |
| No TypeScript | `-UseTypeScript:$false` | `--no-typescript` | Disable TypeScript |
| No SCSS | `-UseSCSS:$false` | `--no-scss` | Disable SCSS |
| Help | `-Help` | `-h, --help` | Show help information |

## 🏗️ Project Types

### 1. Next.js Frontend
Creates a modern React application with:
- Next.js 14+ with App Router
- TypeScript support (configurable)
- SCSS with organized structure
- Component organization (UI, forms, layout)
- Utility functions and hooks
- Type definitions and constants

### 2. Node.js Backend
Creates a robust API server with:
- Express.js framework
- TypeScript support (configurable)
- Organized folder structure (controllers, models, routes, etc.)
- Testing setup with Jest
- Environment configuration
- Logging with Winston

### 3. Full-Stack (Both)
Creates a complete project with:
- Separate `frontend/` and `backend/` directories
- Both Next.js and Node.js setups
- Root README with setup instructions
- Coordinated development workflow

## 📁 Generated Project Structure

### Next.js Project
```
myapp/
├── components/
│   ├── ui/
│   ├── forms/
│   └── layout/
├── hooks/
├── utils/
├── types/
├── constants/
├── services/
├── styles/
│   ├── globals.scss
│   ├── variables.scss
│   ├── mixins.scss
│   └── components.scss
├── public/
│   ├── images/
│   └── icons/
└── ... (Next.js default files)
```

### Node.js Project
```
myapi/
├── src/
│   ├── controllers/
│   ├── models/
│   ├── routes/
│   ├── middleware/
│   ├── services/
│   ├── utils/
│   ├── types/
│   └── config/
├── tests/
│   ├── unit/
│   └── integration/
├── docs/
├── logs/
├── tsconfig.json (if TypeScript)
└── package.json
```

## 🎨 SCSS Features

When SCSS is enabled, the script creates:
- **Variables**: Color schemes, typography, spacing
- **Mixins**: Common patterns like flexbox centering, responsive breakpoints
- **Component Styles**: Organized component styling
- **Global Styles**: Main stylesheet with imports

## 🔧 Configuration

### TypeScript
- Enabled by default
- Modern ES2020 target
- Strict mode enabled
- Decorator support for backend projects

### Package Managers
- **npm**: Default, always available
- **Yarn**: Faster, better dependency resolution
- **pnpm**: Most efficient disk usage

## 🚨 Important Notes

- **Project Names**: Must be lowercase, contain only letters, numbers, and hyphens
- **Directory Cleanup**: Script will prompt before overwriting existing projects
- **Error Handling**: Automatic cleanup on failures to prevent partial setups
- **Cross-Platform**: Both scripts provide identical functionality

## 📝 Examples

### Create a Next.js blog app
```bash
# Windows
.\setup.ps1 -ProjectType "nextjs" -ProjectName "blog-app"

# Linux/macOS
./setup.sh -t "nextjs" -p "blog-app"
```

### Create a full-stack e-commerce project
```bash
# Windows
.\setup.ps1 -ProjectType "both" -ProjectName "ecommerce" -UseYarn

# Linux/macOS
./setup.sh -t "both" -p "ecommerce" --yarn
```

### Create a Node.js API without TypeScript
```bash
# Windows
.\setup.ps1 -ProjectType "nodejs" -ProjectName "api-server" -UseTypeScript:$false

# Linux/macOS
./setup.sh -t "nodejs" -p "api-server" --no-typescript
```

## 🆘 Troubleshooting

### Common Issues

1. **PowerShell Execution Policy**: If you get execution policy errors on Windows, run:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **Permission Denied on Linux/macOS**: Make sure the script is executable:
   ```bash
   chmod +x setup.sh
   ```

3. **Node.js Not Found**: Install Node.js from [nodejs.org](https://nodejs.org/)

4. **Project Name Validation**: Ensure project names follow the naming convention

### Getting Help
```bash
# Windows
.\setup.ps1 -Help

# Linux/macOS
./setup.sh -h
```

## 🤝 Contributing

Feel free to submit issues, feature requests, or pull requests to improve ProjectForge!

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

**Happy coding! 🎉**

