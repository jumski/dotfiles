# Stack Splitting Session

I'll help you break down a feature or change request into a logical stack of smaller, reviewable pieces. This approach leads to faster reviews, reduced risk, and better code quality.

## Let's Start

Please provide the following information about your feature:

### 1. Feature Overview
**What are you trying to build or change?**
- Brief description of the feature/change
- What problem does it solve?

### 2. Acceptance Criteria
**How will you know it's done?**
- List the specific requirements
- What should work when complete?
- Any edge cases or constraints?

### 3. Technical Context
**Tell me about your codebase:**
- What's the main technology stack? (React, Rails, Go, etc.)
- Are there existing patterns for similar features?
- Any architectural constraints or preferences?
- Database changes needed?

### 4. Scope & Timeline
**Project constraints:**
- How large/complex does this feel? (hours, days, weeks?)
- Any hard deadlines or dependencies?
- Are there parts that could ship independently?

## What I'll Help With

Based on your input, I'll suggest:

✅ **Logical breakpoints** - Natural places to split the work  
✅ **Dependency ordering** - Which pieces need to come first  
✅ **Review strategy** - How to make each piece easy to review  
✅ **Deployment approach** - What can ship incrementally  
✅ **Git/PR workflow** - How to structure branches and PRs  

## Example Output

```
Stack Plan: User Authentication System

1. 🗄️  "Add user model and auth tables" 
   - Database schema only
   - No business logic
   - Easy to review, low risk

2. 🔑 "Add basic login/logout endpoints"
   - Core auth flow
   - Depends on #1
   - Can test manually

3. 🔒 "Add password reset flow"  
   - Email templates + endpoints
   - Depends on #2
   - Complete feature ready to ship
```

---

**Ready to start? Share your feature details above and let's create your stack plan!**