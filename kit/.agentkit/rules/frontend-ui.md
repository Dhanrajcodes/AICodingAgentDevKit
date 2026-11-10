# Rule: frontend and UI

The bar: calm, minimal, premium. Stripe-level clarity, Linear-level speed, Apple-level polish. Nothing cheap, gimmicky, text-heavy or recognisably AI-generated. Check every screen against this file before calling it done.

## Design system first
- Use the project's tokens (colour, type, spacing, radius, shadow, motion) and shared components. No raw hex values, ad-hoc spacing or one-off styles in feature code.
- If tokens don't exist yet, define them in one place before building screens. Name colours by role (`surface`, `text-muted`, `accent`, `danger`), not by hue.
- One source of truth for the design system. If two docs disagree, ask which wins and retire the other.
- Don't ship untouched component-library defaults. Restyle to the tokens.
- Visual changes to an approved look need an explicit request.

## Every screen has every state
- **Loading:** skeletons shaped like the content, not spinners on blank pages. No layout shift when data arrives.
- **Empty:** says what this is and the one action to fill it.
- **Error:** what happened in plain words and the quickest fix or retry. Never a raw error dump.
- **Content:** including very long text, one item, many items, and missing optional fields.
- **Partial and offline** where relevant.

## Every control has every state
Default, hover, focus-visible, active, disabled, loading. Async buttons show progress and prevent double submits. Destructive actions confirm or offer undo.

## Accessibility (WCAG 2.2 AA)
- Text contrast ≥ 4.5:1 (≥ 3:1 for large text and UI parts). Check brand colours; many fail on white.
- Full keyboard use, logical focus order, visible focus ring, focus trapped in dialogs and returned after.
- Real elements (`button`, `a`, `label`, `input`), not clickable `div`s. ARIA only where HTML can't express it.
- Every input has a label. Errors are tied to their field and announced.
- Respect reduced motion. Never convey meaning by colour alone.

## Responsive
- Works from 320 px wide up. Touch targets ≥ 44 px. No horizontal scroll on pages.
- Test at 320, 375, 768, 1280 and a wide screen.

## Banned AI-slop patterns
- Gradient text, gradient buttons, glows, neon, glassmorphism, heavy or coloured shadows.
- Emoji as icons. Mixed icon sets or stroke widths.
- Pill badges above every heading, all-caps eyebrow labels that repeat the title, giant stat banners, decorative blobs.
- Made-up metrics, testimonials, logos or "trusted by" rows.
- Centered everything, three identical feature cards as the default layout, hero sections on app screens.
- Pulsing, bouncing or animated decoration on static data.
- Long explanatory paragraphs on product screens. Help goes behind an info affordance or into docs.
- Generic copy: "Unlock", "Supercharge", "Seamless", "Elevate", "Revolutionize", "Effortlessly".

## Layout and type
- One clear primary action per view. Visual hierarchy through size, weight and space, not colour and boxes.
- Generous, consistent spacing from the scale. Align to a grid.
- At most two typefaces. Body text 14-16 px, line length 50-80 characters.
- Status as a badge or dot with a label, not coloured plain text.

## Motion
Short (150-250 ms), soft easing, purposeful: show cause and effect, never decorate. Off under reduced motion.

## Frontend engineering
- Server state in a data-fetching layer with caching; don't hand-roll fetch-in-effect everywhere.
- Validate forms on the client for speed and on the server for truth. Same schema when possible.
- Optimistic updates only with rollback on failure.
- Images sized and lazy-loaded. Watch bundle size; code-split heavy routes.
- No secrets in client code. Treat every client value as untrusted on the server.

## Verify in a real browser
Open the screen (Playwright or the tool's browser) and check each state, both themes if the app has them, keyboard use and mobile width. Save screenshots and reference their paths in the LOG. A screen you didn't open is not done.
