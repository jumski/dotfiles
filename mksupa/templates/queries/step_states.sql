SELECT
    step.step_slug,
    step.output,
    step.status
FROM
    pgflow.step_states step
LEFT JOIN pgflow.runs run USING (run_id)
ORDER BY run.started_at DESC;
