import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'BF6 Portal SDK',
  description: 'Complete documentation for Battlefield 6 Portal SDK - Create custom game modes with TypeScript and Godot',

  ignoreDeadLinks: true, // Temporary - will create missing pages later

  themeConfig: {
    logo: '/logo.svg',

    nav: [
      { text: 'Home', link: '/' },
      { text: 'Getting Started', link: '/guides/getting-started' },
      { text: 'API Reference', link: '/api/' },
      { text: 'Tutorials', link: '/tutorials/' },
      { text: 'Examples', link: '/examples/' }
    ],

    sidebar: {
      '/guides/': [
        {
          text: 'Introduction',
          items: [
            { text: 'What is Portal SDK?', link: '/guides/introduction' },
            { text: 'Getting Started', link: '/guides/getting-started' },
            { text: 'SDK Overview', link: '/guides/sdk-overview' },
            { text: 'Installation', link: '/guides/installation' }
          ]
        },
        {
          text: 'Workflow',
          items: [
            { text: 'Development Workflow', link: '/guides/workflow' },
            { text: 'Godot Spatial Editor', link: '/guides/godot-editor' },
            { text: 'TypeScript Scripting', link: '/guides/typescript-scripting' },
            { text: 'Exporting & Upload', link: '/guides/exporting' }
          ]
        },
        {
          text: 'Core Concepts',
          items: [
            { text: 'Event Hooks', link: '/guides/event-hooks' },
            { text: 'Object System', link: '/guides/object-system' },
            { text: 'Teams & Players', link: '/guides/teams-players' },
            { text: 'Map Objects', link: '/guides/map-objects' }
          ]
        }
      ],

      '/api/': [
        {
          text: 'API Overview',
          items: [
            { text: 'Introduction', link: '/api/' },
            { text: 'Type System', link: '/api/types' },
            { text: 'Enumerations', link: '/api/enums' }
          ]
        },
        {
          text: 'Player System',
          items: [
            { text: 'Player Control', link: '/api/player-control' },
            { text: 'Player State', link: '/api/player-state' },
            { text: 'Player Spawning', link: '/api/player-spawning' },
            { text: 'Player Equipment', link: '/api/player-equipment' }
          ]
        },
        {
          text: 'UI System',
          items: [
            { text: 'UI Overview', link: '/api/ui-overview' },
            { text: 'Widgets', link: '/api/ui-widgets' },
            { text: 'Notifications', link: '/api/ui-notifications' }
          ]
        },
        {
          text: 'AI System',
          items: [
            { text: 'AI Overview', link: '/api/ai-overview' },
            { text: 'AI Behaviors', link: '/api/ai-behaviors' },
            { text: 'AI Combat', link: '/api/ai-combat' }
          ]
        },
        {
          text: 'Spatial & Objects',
          items: [
            { text: 'Object Spawning', link: '/api/object-spawning' },
            { text: 'Object Transform', link: '/api/object-transform' },
            { text: 'Gameplay Objects', link: '/api/gameplay-objects' }
          ]
        },
        {
          text: 'Game Systems',
          items: [
            { text: 'Teams & Scoring', link: '/api/teams-scoring' },
            { text: 'Vehicles', link: '/api/vehicles' },
            { text: 'VFX & Audio', link: '/api/vfx-audio' },
            { text: 'Game Mode', link: '/api/game-mode' }
          ]
        },
        {
          text: 'Utilities',
          items: [
            { text: 'Helper Library (modlib)', link: '/api/modlib' },
            { text: 'Math & Vector', link: '/api/math-vector' }
          ]
        }
      ],

      '/tutorials/': [
        {
          text: 'Beginner Tutorials',
          items: [
            { text: 'Your First Game Mode', link: '/tutorials/first-game-mode' },
            { text: 'Understanding Event Hooks', link: '/tutorials/event-hooks-tutorial' },
            { text: 'Building a Simple UI', link: '/tutorials/simple-ui' },
            { text: 'Working with Teams', link: '/tutorials/teams-tutorial' }
          ]
        },
        {
          text: 'Intermediate Tutorials',
          items: [
            { text: 'Checkpoint System', link: '/tutorials/checkpoint-system' },
            { text: 'Custom Spawning Logic', link: '/tutorials/custom-spawning' },
            { text: 'AI Enemies Setup', link: '/tutorials/ai-enemies' },
            { text: 'Vehicle Racing Mechanics', link: '/tutorials/vehicle-racing' }
          ]
        },
        {
          text: 'Advanced Tutorials',
          items: [
            { text: 'Round-Based Systems', link: '/tutorials/round-based' },
            { text: 'Economy & Buy Phase', link: '/tutorials/economy-system' },
            { text: 'Complex UI Layouts', link: '/tutorials/complex-ui' },
            { text: 'Performance Optimization', link: '/tutorials/optimization' }
          ]
        }
      ],

      '/examples/': [
        {
          text: 'Example Game Modes',
          items: [
            { text: 'Overview', link: '/examples/' },
            { text: 'Vertigo (Climbing Race)', link: '/examples/vertigo' },
            { text: 'AcePursuit (Vehicle Racing)', link: '/examples/acepursuit' },
            { text: 'BombSquad (Tactical Defuse)', link: '/examples/bombsquad' },
            { text: 'Exfil (Extraction)', link: '/examples/exfil' }
          ]
        },
        {
          text: 'Code Snippets',
          items: [
            { text: 'Common Patterns', link: '/examples/common-patterns' },
            { text: 'UI Examples', link: '/examples/ui-examples' },
            { text: 'AI Behaviors', link: '/examples/ai-examples' }
          ]
        }
      ]
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/synthetic-virus' }
    ],

    search: {
      provider: 'local'
    },

    footer: {
      message: 'BF6 Portal SDK Documentation',
      copyright: 'Built by synthetic-virus'
    },

    editLink: {
      pattern: 'https://github.com/synthetic-virus/bf6-portal-docs/edit/main/docs/:path',
      text: 'Edit this page on GitHub'
    }
  },

  markdown: {
    theme: {
      light: 'github-light',
      dark: 'github-dark'
    },
    lineNumbers: true
  },

  head: [
    ['link', { rel: 'icon', href: '/favicon.ico' }],
    ['meta', { name: 'theme-color', content: '#3c8772' }]
  ]
})
