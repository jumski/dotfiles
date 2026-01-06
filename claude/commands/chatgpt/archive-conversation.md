Read the file at ~/Downloads/conversation.md and analyze its content to generate descriptive filename options following this naming convention:

**Naming Pattern:**

- Date prefix: `!(date +%Y-%m-%d)-`
- 3-7 dash-separated keywords (all lowercase)
- Keywords should capture: main topics, project names, actions, contexts, technical terms
- Use specific nouns and abbreviations (e.g., gtm, ats, pgflow, lovable)
- Omit filler words (the, a, for, with, in)
- Examples: `dreambase-salary-estimation`, `pgflow-gtm-funding-linkedin`, `deliverycar-protecting-long-term-rates`

**Procedure:**

1. Read ~/Downloads/conversation.md
2. Identify the main topics, themes, entities discussed
3. Extract 3-6 specific keywords that best summarize the conversation
4. Generate 3-4 different dash-separated filename options
5. Use AskUserQuestion to present the options to the user
6. Move the file to: ~/Code/pgflow-dev/notes/chatgpt/!(date +%Y-%m-%d)-<selected-name>.md

After moving, confirm the new filepath.
