-- Benchmark results focused on throughput
-- Usage: psql -f queries/results.sql

\echo '=== SUMMARY ==='
SELECT
  count(*) AS total_runs,
  count(*) FILTER (WHERE status = 'completed') AS completed,
  count(*) FILTER (WHERE status = 'failed') AS failed,
  count(*) FILTER (WHERE status = 'started') AS in_progress
FROM pgflow.runs;

\echo ''
\echo '=== THROUGHPUT ==='
WITH time_window AS (
  SELECT
    MIN(t.started_at) AS first_task_start,
    MAX(t.completed_at) AS last_task_complete
  FROM pgflow.step_tasks t
  WHERE t.status = 'completed'
)
SELECT
  (SELECT count(*) FROM pgflow.runs WHERE status = 'completed') AS completed_runs,
  (SELECT count(*) FROM pgflow.step_tasks WHERE status = 'completed') AS completed_tasks,
  ROUND(EXTRACT(EPOCH FROM (last_task_complete - first_task_start))::numeric, 2) AS window_seconds,
  ROUND((SELECT count(*) FROM pgflow.runs WHERE status = 'completed')::numeric
        / NULLIF(EXTRACT(EPOCH FROM (last_task_complete - first_task_start)), 0), 2) AS runs_per_sec,
  ROUND((SELECT count(*) FROM pgflow.step_tasks WHERE status = 'completed')::numeric
        / NULLIF(EXTRACT(EPOCH FROM (last_task_complete - first_task_start)), 0), 2) AS tasks_per_sec
FROM time_window;

\echo ''
\echo '=== TASK EXECUTION TIME (ms) - handler duration including DB overhead ==='
SELECT
  step_slug,
  count(*) AS count,
  ROUND(AVG(EXTRACT(EPOCH FROM (completed_at - started_at)) * 1000)::numeric, 1) AS avg,
  ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (completed_at - started_at)) * 1000)::numeric, 1) AS p50,
  ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (completed_at - started_at)) * 1000)::numeric, 1) AS p95
FROM pgflow.step_tasks
WHERE status = 'completed'
GROUP BY step_slug
ORDER BY step_slug;

\echo ''
\echo '=== TASK QUEUE TIME (ms) - wait time before worker picks up ==='
SELECT
  step_slug,
  count(*) AS count,
  ROUND(AVG(EXTRACT(EPOCH FROM (started_at - queued_at)) * 1000)::numeric, 1) AS avg,
  ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (started_at - queued_at)) * 1000)::numeric, 1) AS p50,
  ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (started_at - queued_at)) * 1000)::numeric, 1) AS p95
FROM pgflow.step_tasks
WHERE status = 'completed' AND started_at IS NOT NULL
GROUP BY step_slug
ORDER BY step_slug;

\echo ''
\echo '=== FAILED TASKS ==='
SELECT
  step_slug,
  count(*) AS failed_count,
  array_agg(DISTINCT LEFT(error_message, 60)) AS errors
FROM pgflow.step_tasks
WHERE status = 'failed'
GROUP BY step_slug;
