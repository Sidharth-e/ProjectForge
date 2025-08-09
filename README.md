# ProjectForge

A powerful PowerShell script to quickly create Next.js and Node.js projects with the latest versions and proper folder structures.

## Features

- 🚀 **Latest Versions**: Always uses the most recent versions of Next.js and Node.js
- 📁 **Proper Structure**: Creates well-organized folder structures for both project types
- 🎨 **SCSS Support**: Built-in SCSS support for Next.js projects (no Tailwind by default)
- 📝 **TypeScript Ready**: Full TypeScript support for both project types
- 🔧 **Package Manager Support**: Works with npm, yarn, or pnpm
- 🎯 **Flexible Options**: Create Next.js, Node.js, or both projects simultaneously

## Prerequisites

- Windows PowerShell 5.1 or PowerShell Core 6+
- Node.js (latest LTS version recommended)
- npm, yarn, or pnpm (optional, npm will be used if others aren't available)

## Usage

### Basic Usage

```powershell
# Create a Next.js project
.\setup.ps1 -ProjectType "nextjs" -ProjectName "my-nextjs-app"

# Create a Node.js project
.\setup.ps1 -ProjectType "nodejs" -ProjectName "my-nodejs-api"

# Create both projects in one go
.\setup.ps1 -ProjectType "both" -ProjectName "my-fullstack-app"
```

### Advanced Options

```powershell
# Use specific package manager
.\setup.ps1 -ProjectType "nextjs" -ProjectName "my-app" -UseYarn

# Disable TypeScript
.\setup.ps1 -ProjectType "nextjs" -ProjectName "my-app" -UseTypeScript:$false

# Disable SCSS (will use CSS instead)
.\setup.ps1 -ProjectType "nextjs" -ProjectName "my-app" -UseSCSS:$false

# Specify custom project path
.\setup.ps1 -ProjectType "nextjs" -ProjectName "my-app" -ProjectPath "C:\Projects"
```

## Project Types

### Next.js Project Structure

```
my-nextjs-app/
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

### Node.js Project Structure

```
my-nodejs-api/
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
├── tsconfig.json (if TypeScript enabled)
└── package.json
```

### Both Projects Structure

```
my-fullstack-app/
├── frontend/          # Next.js application
├── backend/           # Node.js API server
└── README.md          # Project documentation
```

## Package Managers

The script automatically detects and uses the best available package manager:

1. **yarn** (if `-UseYarn` flag is set and yarn is available)
2. **pnpm** (if `-UsePnpm` flag is set and pnpm is available)
3. **npm** (default fallback)

## Dependencies

### Next.js Dependencies
- Latest Next.js version
- React and React DOM
- TypeScript (if enabled)
- SCSS support (if enabled)

### Node.js Dependencies
- Express.js
- CORS, Helmet, Morgan
- Winston for logging
- Jest for testing
- TypeScript (if enabled)
- Development tools (nodemon, ts-node-dev)

## Examples

### Example 1: Quick Next.js Setup
```powershell
.\setup.ps1 -ProjectType "nextjs" -ProjectName "portfolio-website"
```

### Example 2: Full-Stack Project with Yarn
```powershell
.\setup.ps1 -ProjectType "both" -ProjectName "ecommerce-app" -UseYarn
```

### Example 3: Node.js API with Custom Path
```powershell
.\setup.ps1 -ProjectType "nodejs" -ProjectName "user-api" -ProjectPath "C:\APIs"
```

## Quick Start with ProjectForge

```powershell
# Create a modern Next.js app
.\setup.ps1 -ProjectType "nextjs" -ProjectName "my-awesome-app"

# Create a full-stack project
.\setup.ps1 -ProjectType "both" -ProjectName "my-fullstack-project"
```

## After Setup

Once your project is created, follow these steps:

### For Next.js Projects
```bash
cd your-project-name
npm install  # or yarn install / pnpm install
npm run dev  # or yarn dev / pnpm dev
```

### For Node.js Projects
```bash
cd your-project-name
npm install  # or yarn install / pnpm install
npm run dev  # or yarn dev / pnpm dev
```

### For Both Projects
```bash
cd your-project-name

# Frontend
cd frontend
npm install
npm run dev

# Backend (in new terminal)
cd backend
npm install
npm run dev
```

## Troubleshooting

### Common Issues

1. **PowerShell Execution Policy**: If you get execution policy errors, run:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **Node.js Not Found**: Make sure Node.js is installed and in your PATH

3. **Permission Denied**: Run PowerShell as Administrator if needed

### Error Messages

- **"Node.js is not installed"**: Install Node.js from [nodejs.org](https://nodejs.org/)
- **"Project directory already exists"**: Choose to overwrite or use a different name
- **"Package manager not found"**: The script will fall back to npm

## Contributing

Feel free to submit issues and enhancement requests to help improve ProjectForge!

## License

ProjectForge is open source and available under the MIT License.

