# Documentation Site Quick Start

## First Time Setup

1. **Install Dependencies**
   ```bash
   cd "BF6 Portal SDK/docs-site"
   npm install
   ```

2. **Start Development Server**
   ```bash
   npm run docs:dev
   ```
   Or use the helper script:
   ```bash
   ./start-dev.sh
   ```

3. **Open in Browser**
   Navigate to: `http://localhost:5173`

## Development Commands

| Command | Purpose |
|---------|---------|
| `npm run docs:dev` | Start development server with hot-reload |
| `npm run docs:build` | Build production static site |
| `npm run docs:preview` | Preview production build locally |

## Adding New Content

### Create a New Page

1. Add `.md` file in appropriate directory:
   - Guides: `docs/guides/my-guide.md`
   - API Docs: `docs/api/my-api.md`
   - Tutorials: `docs/tutorials/my-tutorial.md`
   - Examples: `docs/examples/my-example.md`

2. Add frontmatter (optional):
   ```markdown
   ---
   title: My Page Title
   description: Page description
   ---

   # My Page Title
   Content here...
   ```

3. Update sidebar in `docs/.vitepress/config.mjs`:
   ```javascript
   '/guides/': [
     {
       text: 'My Section',
       items: [
         { text: 'My Guide', link: '/guides/my-guide' }
       ]
     }
   ]
   ```

### Markdown Features

#### Code Blocks
````markdown
```typescript
export async function OnGameModeStarted() {
  console.log("Hello!");
}
```
````

#### Custom Containers
```markdown
::: tip Helpful Tip
This is a tip!
:::

::: warning Be Careful
This is a warning!
:::

::: danger Critical
This is critical information!
:::
```

#### Tables
```markdown
| Column 1 | Column 2 |
|----------|----------|
| Value 1  | Value 2  |
```

## Project Structure

```
docs-site/
├── docs/
│   ├── .vitepress/
│   │   ├── config.mjs         # Site configuration
│   │   └── theme/
│   │       ├── index.js       # Theme entry
│   │       └── custom.css     # Custom styles
│   ├── api/                   # API reference
│   ├── guides/                # Guides
│   ├── tutorials/             # Tutorials
│   ├── examples/              # Examples
│   ├── public/                # Static files
│   └── index.md               # Homepage
├── package.json
├── README.md
└── QUICKSTART.md (this file)
```

## Troubleshooting

### Port Already in Use
```bash
npm run docs:dev -- --port 3000
```

### Build Fails
```bash
rm -rf node_modules
npm install
```

### Changes Not Showing
- Hard refresh browser (Ctrl+F5)
- Clear browser cache
- Restart dev server

## Deployment

### Build for Production
```bash
npm run docs:build
```

Output: `docs/.vitepress/dist/`

### Deploy to GitHub Pages
See `README.md` for GitHub Actions workflow.

### Deploy to Netlify
1. Connect GitHub repository
2. Build command: `npm run docs:build`
3. Publish directory: `docs/.vitepress/dist`

## Links

- **Development**: http://localhost:5173
- **VitePress Docs**: https://vitepress.dev/
- **Markdown Guide**: https://www.markdownguide.org/

---

Happy documenting! 📚
