# Battlefield 6 Portal SDK Documentation

Complete, community-created documentation for the Battlefield 2042 Portal SDK. Build custom game modes with TypeScript and Godot 4.4.1.

🌐 **Repository:** https://github.com/Synthetic-Virus/bf6-portal-sdk-docs

## 📚 What's Included

### API Reference (18 Pages)
Complete documentation for all **545+ SDK functions**:

- **Player System** - Control, State, Spawning, Equipment (120+ functions)
- **UI System** - Widgets, Notifications, Layouts (104+ functions)
- **AI System** - Behaviors, Combat, Pathing (25+ functions)
- **Game Systems** - Teams, Scoring, Vehicles, VFX & Audio (115+ functions)
- **Spatial Objects** - Spawning, Transform, Gameplay Objects (80+ functions)
- **Utilities** - Math, Vector operations, Helper library (modlib)

### Example Game Modes (4 Complete Walkthroughs)

1. **[Vertigo](docs/examples/vertigo.md)** - 4-team vertical climbing race (308 lines)
2. **[AcePursuit](docs/examples/acepursuit.md)** - 8-player vehicle racing with lap tracking (~800 lines)
3. **[BombSquad](docs/examples/bombsquad.md)** - 5v5 tactical bomb defusal with economy system (~800 lines)
4. **[Exfil](docs/examples/exfil.md)** - 4-team extraction mode with AI enemies (~1000 lines)

Each example includes:
- Complete architecture breakdown
- Working code snippets
- Implementation checklists
- Design pattern analysis
- UI component descriptions

### Guides
- **Getting Started** - Complete SDK setup walkthrough
- **Godot Editor** - Spatial editor usage
- **TypeScript Scripting** - Game logic development
- **Event Hooks** - 7 event system explained
- **Workflow** - Development to deployment pipeline

---

# BF6 Portal SDK Documentation Website

Modern, responsive documentation website for the Battlefield 6 Portal SDK built with VitePress.

## Features

- ✅ **545 API Functions** fully documented with examples
- ✅ **Comprehensive Getting Started** guide
- ✅ **4 Example Game Modes** with detailed walkthroughs
- ✅ **Responsive Design** - works on desktop, tablet, and mobile
- ✅ **Dark Mode** support
- ✅ **Search** functionality
- ✅ **Code Highlighting** with line numbers
- ✅ **Modern UI** with Battlefield-inspired colors

## Quick Start

### Prerequisites

- Node.js 18+ installed
- npm or yarn package manager

### Installation

```bash
cd docs-site
npm install
```

### Development Server

Run the development server with hot-reload:

```bash
npm run docs:dev
```

The site will be available at `http://localhost:5173`

### Build for Production

Generate static HTML files:

```bash
npm run docs:build
```

Output will be in `docs/.vitepress/dist/`

### Preview Production Build

Preview the production build locally:

```bash
npm run docs:preview
```

## Project Structure

```
docs-site/
├── docs/
│   ├── .vitepress/
│   │   ├── config.js          # VitePress configuration
│   │   └── theme/
│   │       ├── index.js       # Theme configuration
│   │       └── custom.css     # Custom styles
│   ├── api/                   # API reference pages
│   │   ├── index.md
│   │   ├── player-control.md
│   │   ├── ui-widgets.md
│   │   └── ...
│   ├── guides/                # Tutorial guides
│   │   ├── getting-started.md
│   │   ├── workflow.md
│   │   └── ...
│   ├── tutorials/             # Step-by-step tutorials
│   ├── examples/              # Example game modes
│   │   ├── vertigo.md
│   │   ├── acepursuit.md
│   │   └── ...
│   ├── public/                # Static assets
│   └── index.md               # Homepage
├── package.json
└── README.md (this file)
```

## Adding New Content

### New Guide Page

1. Create `.md` file in `docs/guides/`
2. Add frontmatter and content
3. Update sidebar in `docs/.vitepress/config.js`

Example:

```markdown
---
title: My New Guide
---

# My New Guide

Content here...
```

### New API Reference Page

1. Create `.md` file in `docs/api/`
2. Document functions with code examples
3. Add to sidebar in config.js

### Code Examples

Use fenced code blocks with language:

````markdown
```typescript
import * as mod from 'bf-portal-api';

export async function OnGameModeStarted() {
  console.log("Game started!");
}
```
````

### Custom Containers

Use VitePress containers for special callouts:

```markdown
::: tip Pro Tip
This is a helpful tip!
:::

::: warning Watch Out
This is a warning!
:::

::: danger Critical
This is critical information!
:::

::: details Click to Expand
Hidden content that expands on click
:::
```

## Customization

### Colors

Edit colors in `docs/.vitepress/theme/custom.css`:

```css
:root {
  --vp-c-brand: #3c8772;       /* Primary brand color */
  --vp-c-brand-light: #4a9d85;
  --vp-c-brand-dark: #2e6b5a;
}
```

### Logo

Place logo file in `docs/public/logo.svg` and reference in config:

```javascript
themeConfig: {
  logo: '/logo.svg'
}
```

### Navigation

Edit navigation in `docs/.vitepress/config.js`:

```javascript
nav: [
  { text: 'Home', link: '/' },
  { text: 'API', link: '/api/' }
]
```

## Deployment Options

### Static Hosting

The built site (in `docs/.vitepress/dist/`) can be hosted on:

- **GitHub Pages** - Free, automatic builds with GitHub Actions
- **Netlify** - Free tier, automatic builds from git
- **Vercel** - Free tier, optimized for static sites
- **Cloudflare Pages** - Free tier, global CDN
- **AWS S3 + CloudFront** - Scalable, pay-as-you-go

### GitHub Pages Deployment

1. Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy Docs

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      - run: npm ci
      - run: npm run docs:build
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: docs/.vitepress/dist
```

2. Enable GitHub Pages in repository settings
3. Push to main branch

### Netlify Deployment

1. Connect GitHub repository
2. Set build command: `npm run docs:build`
3. Set publish directory: `docs/.vitepress/dist`
4. Deploy!

## Performance

The built site is optimized for performance:

- ✅ Static HTML generation
- ✅ Code splitting
- ✅ Lazy loading
- ✅ Optimized assets
- ✅ Service worker for offline access (optional)

## Browser Support

- Chrome/Edge (latest 2 versions)
- Firefox (latest 2 versions)
- Safari (latest 2 versions)
- Mobile browsers (iOS Safari, Chrome Mobile)

## Contributing

### Content Guidelines

- Use clear, concise language
- Include code examples for every concept
- Add warnings for common pitfalls
- Link to related pages
- Test all code examples

### Code Style

- Use TypeScript for all examples
- Follow consistent formatting
- Add comments for complex logic
- Use descriptive variable names

## Maintenance

### Updating Dependencies

```bash
npm update
```

### Checking for Vulnerabilities

```bash
npm audit
npm audit fix
```

## Troubleshooting

### Port Already in Use

Change the default port:

```bash
npm run docs:dev -- --port 3000
```

### Build Fails

1. Clear cache: `rm -rf node_modules/.vite`
2. Reinstall: `rm -rf node_modules && npm install`
3. Check Node version: `node --version` (must be 18+)

### Search Not Working

Search is built into VitePress and works automatically. If issues:

1. Rebuild the site
2. Clear browser cache
3. Check browser console for errors

## Resources

- [VitePress Documentation](https://vitepress.dev/)
- [Markdown Guide](https://www.markdownguide.org/)
- [Vue.js](https://vuejs.org/)

## License

ISC License - See parent SDK for terms

## Author

synthetic-virus (andrew@virusgaming.org)

## Support

For questions or issues:
- Check the documentation first
- Email: andrew@virusgaming.org
- Review example pages for patterns

---

**Version**: 1.0.0
**Last Updated**: 2025-10-09
