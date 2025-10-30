# Lovable Prompt Examples

Real-world examples of well-structured Lovable prompts for different implementation phases.

## Table of Contents
- [Phase 0: Setup Example](#phase-0-setup-example)
- [Phase 1: Frontend Mock Example](#phase-1-frontend-mock-example)
- [Phase 2: Backend Integration Example](#phase-2-backend-integration-example)
- [Phase 3: Polish Example](#phase-3-polish-example)
- [Advanced Patterns](#advanced-patterns)

---

## Phase 0: Setup Example

**File**: `00-setup-knowledge-base.md`

```markdown
# Project Setup - Task Management App

**Recommended Mode**: Chat Mode

---

## Context

Starting a new task management application for small teams.

**Tech Stack** (from PRD):
- Frontend: Next.js 14, React, TypeScript, Tailwind CSS
- UI Components: shadcn/ui
- Backend: Supabase (auth, database, real-time)
- Deployment: Vercel

---

## Task

Create a Knowledge Base entry for this project with the complete PRD. Review and confirm understanding before any code is written.

**Goal**: Establish shared context between user and AI for all future prompts.

---

## Guidelines

**PRD Summary** (to be added to Knowledge Base):

**Project Overview**: Team-focused task management app with projects, tasks, assignments, and due dates.

**Core Features** (In-Scope):
- User authentication (email/password)
- Project creation and management
- Task CRUD operations (create, read, update, delete)
- Task assignment to team members
- Due date tracking and reminders
- Dashboard overview with project status

**Out of Scope** (for MVP):
- Real-time collaboration (chat, comments)
- File attachments
- Third-party integrations (Slack, etc.)
- Mobile native apps

**User Flows**:
1. User signs up/logs in → Dashboard
2. Dashboard shows list of projects
3. User creates new project → Project detail page
4. User creates tasks within project
5. User assigns tasks to team members
6. Dashboard shows overdue/upcoming tasks

**Integrations Needed**:
- `[Supabase]` for authentication and database
- `[shadcn/ui]` for UI components

**API Key Requirements**:
- Supabase: SUPABASE_URL, SUPABASE_ANON_KEY

---

## Constraints

This is a planning-only prompt. Do NOT write any code yet.

---

## Deliverables Checklist

- [ ] Knowledge Base contains complete PRD summary above
- [ ] Tech stack confirmed: Next.js, TypeScript, Tailwind, shadcn/ui, Supabase
- [ ] Core features list documented (6 features in-scope)
- [ ] Out-of-scope items clearly stated
- [ ] User flows documented
- [ ] Integration requirements noted with API key needs

---

## Next Steps

After Knowledge Base is populated:
- Prompt 01: Build dashboard page with mock project data
- Prompt 02: Build project detail page with mock task data
- Later prompts: Replace mocks with Supabase integration
```

---

## Phase 1: Frontend Mock Example

**File**: `01-dashboard-mock.md`

```markdown
# Dashboard Page - Mock Implementation

**Recommended Mode**: Default Mode

---

## Context

**Project**: Task Management App (see Knowledge Base)

**Tech Stack**: Next.js 14, TypeScript, Tailwind CSS, shadcn/ui

**Knowledge Base**: Review the project requirements before starting.

**Current State**: Empty project, this is the first feature.

---

## Task

Build the main Dashboard page that displays a list of projects with their status. Use mock data for now - no backend integration yet.

**Goal**: User can see a clean, responsive dashboard showing project cards with status indicators.

---

## Guidelines

**Implementation Details**:
- Create `app/dashboard/page.tsx` as the main dashboard route
- Create `components/ProjectCard.tsx` component for individual project display
- Create `lib/mocks/projectService.ts` mock adapter class
- Use TypeScript interfaces: `Project { id, name, description, status, taskCount, completedCount }`

**Mock Data Pattern**:
```typescript
// lib/mocks/projectService.ts
export class MockProjectService {
  async getProjects(): Promise<Project[]> {
    return [
      {
        id: "1",
        name: "Website Redesign",
        description: "Refresh company website",
        status: "active",
        taskCount: 12,
        completedCount: 5
      },
      {
        id: "2",
        name: "Mobile App",
        description: "Build iOS/Android app",
        status: "planning",
        taskCount: 8,
        completedCount: 0
      }
    ];
  }
}
```

**UI Components**:
- Use `[shadcn/ui]` Card component for project cards
- Include project name, description, and progress bar
- Show "Create New Project" button (non-functional for now)
- Use grid layout (responsive: 1 col mobile, 2 cols tablet, 3 cols desktop)

**Styling & UX**:
- Clean, modern design with good spacing
- Status badge with color coding (active=green, planning=blue, completed=gray)
- Progress bar showing completedCount/taskCount
- Responsive using Tailwind breakpoints (sm, md, lg)

---

## Constraints

**Do NOT modify**:
- No files to avoid yet (first feature)

**Focus ONLY on**:
- `app/dashboard/page.tsx` - Dashboard route
- `components/ProjectCard.tsx` - Project card component
- `lib/mocks/projectService.ts` - Mock data service
- `types/project.ts` - TypeScript types

**Behavior Constraints**:
- Use ONLY mock data, no API calls
- "Create New Project" button can be placeholder (no action)
- No authentication check needed yet (will add later)

---

## Deliverables Checklist

After completing this prompt, verify:

- [ ] Dashboard page renders at `/dashboard` route
- [ ] Two mock projects display as cards with names and descriptions
- [ ] Progress bar shows "5/12" and "0/8" for respective projects
- [ ] Status badges display with correct colors (green/blue)
- [ ] "Create New Project" button is visible (even if non-functional)
- [ ] Layout is responsive: 1 column on mobile, 3 columns on desktop
- [ ] No console errors, app runs without issues

---

## Next Steps

After verification:
- Prompt 02: Build project detail page (clicking a card navigates there)
- Prompt 03: Add task list within project detail (also mocked)
- Later: Replace MockProjectService with real Supabase queries
```

---

## Phase 2: Backend Integration Example

**File**: `05-integrate-supabase-projects.md`

```markdown
# Supabase Integration - Projects

**Recommended Mode**: Default Mode

---

## Context

**Project**: Task Management App (see Knowledge Base)

**Tech Stack**: Next.js 14, TypeScript, Supabase

**Knowledge Base**: Review project requirements and database schema.

**Current State**: Dashboard displays projects using MockProjectService. Now we replace the mock with real Supabase integration.

---

## Task

Replace `MockProjectService` with `SupabaseProjectService` that fetches projects from the Supabase database. Keep the frontend behavior exactly the same.

**Goal**: Dashboard now displays real project data from Supabase instead of hardcoded mocks.

---

## Guidelines

**Implementation Details**:
- Create `lib/services/supabaseProjectService.ts`
- Use `[Supabase]` client for database queries
- Implement the same interface as MockProjectService (drop-in replacement)
- Query the `projects` table with proper typing

**Database Schema** (ensure this exists in Supabase):
```sql
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'planning',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  user_id UUID REFERENCES auth.users(id)
);
```

**Service Implementation**:
```typescript
// lib/services/supabaseProjectService.ts
import { createClient } from '@/lib/supabase/client';

export class SupabaseProjectService {
  async getProjects(): Promise<Project[]> {
    const supabase = createClient();
    const { data, error } = await supabase
      .from('projects')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) throw error;

    // Transform to match Project interface
    return data.map(row => ({
      id: row.id,
      name: row.name,
      description: row.description,
      status: row.status,
      taskCount: 0, // Will calculate from tasks table later
      completedCount: 0
    }));
  }
}
```

**Integration Steps**:
1. Create Supabase client setup if not exists
2. Implement SupabaseProjectService with same method signatures
3. Update `app/dashboard/page.tsx` to use SupabaseProjectService instead of Mock
4. Add error handling and loading states
5. Test with real data in Supabase

**Supabase Setup**:
- Ensure `SUPABASE_URL` and `SUPABASE_ANON_KEY` are in `.env.local`
- Create `projects` table if not exists
- Add Row Level Security (RLS) policy: users can only see their own projects

---

## Constraints

**Do NOT modify**:
- `components/ProjectCard.tsx` - Keep UI exactly the same
- `types/project.ts` - Keep Project interface unchanged
- Any other pages or components

**Focus ONLY on**:
- `lib/services/supabaseProjectService.ts` - New service implementation
- `lib/supabase/client.ts` - Supabase client setup (create if needed)
- `app/dashboard/page.tsx` - Switch from Mock to Supabase service
- Add loading/error states to dashboard

**Behavior Constraints**:
- Frontend should look and behave identically
- If Supabase query fails, show user-friendly error message
- Add loading spinner while data fetches
- Keep the same Project interface (taskCount/completedCount can be 0 for now)

---

## Deliverables Checklist

After completing this prompt, verify:

- [ ] Dashboard fetches projects from Supabase `projects` table
- [ ] Projects display with real data (create 2-3 test projects in Supabase to verify)
- [ ] Loading spinner appears briefly while fetching
- [ ] Error message displays if Supabase connection fails
- [ ] UI looks identical to mock version (same layout, colors, responsiveness)
- [ ] RLS policy ensures users only see their own projects
- [ ] No console errors, app runs without issues

---

## Next Steps

After verification:
- Prompt 06: Integrate Supabase for tasks within projects
- Prompt 07: Calculate real taskCount and completedCount
- Prompt 08: Add "Create New Project" functionality (POST to Supabase)
```

---

## Phase 3: Polish Example

**File**: `09-dashboard-responsive-polish.md`

```markdown
# Dashboard Responsive Polish

**Recommended Mode**: Default Mode

---

## Context

**Project**: Task Management App (see Knowledge Base)

**Tech Stack**: Next.js 14, TypeScript, Tailwind CSS

**Knowledge Base**: Review project requirements.

**Current State**: Dashboard is functional with Supabase integration. Now improve responsiveness and visual polish.

---

## Task

Enhance the Dashboard page to be fully responsive across all devices with improved UX polish. This is a **visual-only** update - do not change any functionality.

**Goal**: Dashboard looks professional and works perfectly on mobile, tablet, and desktop.

---

## Guidelines

**Responsiveness Improvements**:
- Mobile (< 640px): Single column, larger touch targets
- Tablet (640px - 1024px): Two columns, balanced spacing
- Desktop (> 1024px): Three columns with generous whitespace
- Use Tailwind breakpoints: `sm:`, `md:`, `lg:`

**UX Polish**:
- Add subtle hover effects on ProjectCard (scale, shadow)
- Improve loading skeleton (instead of spinner)
- Add empty state when no projects exist
- Enhance spacing and typography hierarchy
- Smooth transitions for interactive elements

**Accessibility**:
- Ensure all interactive elements have proper focus states
- Add aria-labels where needed
- Maintain color contrast ratios (WCAG AA)

---

## Constraints

**Do NOT modify**:
- `lib/services/supabaseProjectService.ts` - Backend logic stays unchanged
- Data fetching logic in dashboard - Keep queries identical
- Project card content or data structure

**Focus ONLY on**:
- `app/dashboard/page.tsx` - Layout and responsive classes
- `components/ProjectCard.tsx` - Hover effects, transitions
- CSS/Tailwind classes only - no functional changes

**Behavior Constraints**:
- **Purely visual changes - functionality must remain identical**
- Do not change data fetching, error handling, or loading logic
- Do not modify TypeScript types or interfaces
- Keep all click handlers and navigation working exactly as before

---

## Deliverables Checklist

After completing this prompt, verify:

- [ ] Dashboard displays correctly on iPhone SE (375px width)
- [ ] Dashboard displays correctly on iPad (768px width)
- [ ] Dashboard displays correctly on desktop (1920px width)
- [ ] Project cards have subtle hover effect (gentle scale/shadow)
- [ ] Empty state displays when no projects exist (with helpful message)
- [ ] Loading shows skeleton cards instead of spinner
- [ ] All interactive elements have visible focus states
- [ ] Spacing and typography look polished and professional
- [ ] All existing functionality still works (navigation, data fetching, errors)

---

## Next Steps

After verification:
- Dashboard UI complete
- Move on to polishing project detail page
```

---

## Advanced Patterns

### Pattern: Multi-Step Feature

For complex features, break into multiple prompts:

1. **UI Structure**: Build layout and navigation (mock data)
2. **Core Logic**: Add main feature logic (still mock data)
3. **Edge Cases**: Handle errors, empty states, loading
4. **Backend**: Replace mocks with real integration
5. **Polish**: Responsiveness, accessibility, UX refinements

### Pattern: Scope with Dependencies

When features depend on each other:

```markdown
## Constraints

**Prerequisites** (must be completed first):
- Dashboard page with project list (Prompt 01)
- Project detail page with task list (Prompt 02)

**Do NOT modify**:
- Dashboard page - it's working correctly
- Project list logic - keep existing queries

**Focus ONLY on**:
- Task creation form
- POST endpoint for new tasks
```

### Pattern: Integration with API Keys

```markdown
## Guidelines

**Integration Setup**:
- Use `[Stripe]` for payment processing
- Required environment variables:
  - `STRIPE_PUBLIC_KEY` (client-side)
  - `STRIPE_SECRET_KEY` (server-side, in Supabase Edge Function)
  - `STRIPE_WEBHOOK_SECRET` (for webhook verification)

**Test Mode**:
- Use Stripe test mode for development
- Product ID: `prod_test123` (from Stripe dashboard)
- Price ID: `price_test456`

**Webhook Setup Instructions**:
After implementation, configure Stripe webhook:
1. Go to Stripe Dashboard → Webhooks
2. Add endpoint: `https://[your-project].supabase.co/functions/v1/stripe-webhook`
3. Select events: `checkout.session.completed`, `payment_intent.succeeded`
```

### Pattern: Refactoring Existing Code

```markdown
# Refactor Dashboard Components

**Recommended Mode**: Default Mode

---

## Task

Refactor the Dashboard page components for better maintainability. **Keep behavior and UI exactly the same** - this is purely code cleanup.

---

## Guidelines

**Refactoring Goals**:
- Extract repeated logic into custom hooks
- Break large components into smaller, focused ones
- Improve TypeScript typing (remove `any` types)
- Add JSDoc comments to complex functions

**Safe Refactoring Checklist**:
- [ ] Extract `useProjects` hook from dashboard page
- [ ] Split ProjectCard into ProjectCard + ProjectProgress subcomponents
- [ ] Move status badge logic to `getStatusBadgeColor` utility
- [ ] Add proper TypeScript generics to API functions

---

## Constraints

**Critical**:
- **Zero functional changes** - app must behave identically
- **Zero visual changes** - UI must look identical
- Keep the same file structure (just internal organization)

**Validation**:
After refactoring, confirm:
- [ ] Dashboard looks exactly the same
- [ ] All interactions work identically
- [ ] No new console errors or warnings
- [ ] TypeScript compiles without errors
```

## Tips for Generating Great Prompts

1. **Start Broad, Then Narrow**: Phase 0 = big picture, later phases = specific components
2. **Mock Everything First**: Don't integrate backend until frontend is solid
3. **One Integration Per Prompt**: Don't combine Supabase + Stripe in one prompt
4. **Explicit Scope Locks**: List every file that shouldn't be touched
5. **Visual Verification**: Deliverables should be checkable by looking at the UI
6. **Reference PRD Always**: Keep AI grounded in project requirements
7. **Plan for Polish**: Last 1-2 prompts should be pure UX/responsiveness refinement
