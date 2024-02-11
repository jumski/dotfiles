complete -c turbo -n "__fish_use_subcommand" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_use_subcommand" -l cpuprofile -d 'Specify a file to save a cpu profile' -r
complete -c turbo -n "__fish_use_subcommand" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_use_subcommand" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_use_subcommand" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_use_subcommand" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_use_subcommand" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_use_subcommand" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_use_subcommand" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_use_subcommand" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_use_subcommand" -l cache-dir -d 'Override the filesystem cache directory' -r
complete -c turbo -n "__fish_use_subcommand" -l cache-workers -d 'Set the number of concurrent cache operations (default 10)' -r
complete -c turbo -n "__fish_use_subcommand" -l concurrency -d 'Limit the concurrency of task execution. Use 1 for serial (i.e. one-at-a-time) execution' -r
complete -c turbo -n "__fish_use_subcommand" -l dry-run -r -f -a "{text	'',json	''}"
complete -c turbo -n "__fish_use_subcommand" -s F -l filter -d 'Use the given selector to specify package(s) to act as entry points. The syntax mirrors pnpm\'s syntax, and additional documentation and examples can be found in turbo\'s documentation https://turbo.build/repo/docs/reference/command-line-reference/run#--filter' -r
complete -c turbo -n "__fish_use_subcommand" -l force -d 'Ignore the existing cache (to force execution)' -r -f -a "{true	'',false	''}"
complete -c turbo -n "__fish_use_subcommand" -l framework-inference -d 'Specify whether or not to do framework inference for tasks' -r -f -a "{true	'',false	''}"
complete -c turbo -n "__fish_use_subcommand" -l global-deps -d 'Specify glob of global filesystem dependencies to be hashed. Useful for .env and files' -r
complete -c turbo -n "__fish_use_subcommand" -l graph -d 'Generate a graph of the task execution and output to a file when a filename is specified (.svg, .png, .jpg, .pdf, .json, .html). Outputs dot graph to stdout when if no filename is provided' -r
complete -c turbo -n "__fish_use_subcommand" -l env-mode -d 'Environment variable mode. Use "loose" to pass the entire existing environment. Use "strict" to use an allowlist specified in turbo.json. Use "infer" to defer to existence of "passThroughEnv" or "globalPassThroughEnv" in turbo.json. (default infer)' -r -f -a "{infer	'',loose	'',strict	''}"
complete -c turbo -n "__fish_use_subcommand" -l ignore -d 'Files to ignore when calculating changed files (i.e. --since). Supports globs' -r
complete -c turbo -n "__fish_use_subcommand" -l output-logs -d 'Set type of process output logging. Use "full" to show all output. Use "hash-only" to show only turbo-computed task hashes. Use "new-only" to show only new output with only hashes for cached tasks. Use "none" to hide process output. (default full)' -r -f -a "{full	'',none	'',hash-only	'',new-only	'',errors-only	''}"
complete -c turbo -n "__fish_use_subcommand" -l log-order -d 'Set type of task output order. Use "stream" to show output as soon as it is available. Use "grouped" to show output when a command has finished execution. Use "auto" to let turbo decide based on its own heuristics. (default auto)' -r -f -a "{auto	'',stream	'',grouped	''}"
complete -c turbo -n "__fish_use_subcommand" -l pkg-inference-root -r
complete -c turbo -n "__fish_use_subcommand" -l profile -d 'File to write turbo\'s performance profile output into. You can load the file up in chrome://tracing to see which parts of your build were slow' -r
complete -c turbo -n "__fish_use_subcommand" -l anon-profile -d 'File to write turbo\'s performance profile output into. All identifying data omitted from the profile' -r
complete -c turbo -n "__fish_use_subcommand" -l remote-only -d 'Ignore the local filesystem cache for all tasks. Only allow reading and caching artifacts using the remote cache' -r -f -a "{true	'',false	''}"
complete -c turbo -n "__fish_use_subcommand" -l remote-cache-read-only -d 'Treat remote cache as read only' -r -f -a "{true	'',false	''}"
complete -c turbo -n "__fish_use_subcommand" -l scope -d 'Specify package(s) to act as entry points for task execution. Supports globs' -r
complete -c turbo -n "__fish_use_subcommand" -l since -d 'Limit/Set scope to changed packages since a mergebase. This uses the git diff ${target_branch}... mechanism to identify which packages have changed' -r
complete -c turbo -n "__fish_use_subcommand" -l summarize -d 'Generate a summary of the turbo run' -r -f -a "{true	'',false	''}"
complete -c turbo -n "__fish_use_subcommand" -l log-prefix -d 'Use "none" to remove prefixes from task logs. Use "task" to get task id prefixing. Use "auto" to let turbo decide how to prefix the logs based on the execution environment. In most cases this will be the same as "task". Note that tasks running in parallel interleave their logs, so removing prefixes can make it difficult to associate logs with tasks. Use --log-order=grouped to prevent interleaving. (default auto)' -r -f -a "{auto	'',none	'',task	''}"
complete -c turbo -n "__fish_use_subcommand" -l experimental-space-id -r
complete -c turbo -n "__fish_use_subcommand" -l version
complete -c turbo -n "__fish_use_subcommand" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_use_subcommand" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_use_subcommand" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_use_subcommand" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_use_subcommand" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_use_subcommand" -s v
complete -c turbo -n "__fish_use_subcommand" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_use_subcommand" -l __test-run
complete -c turbo -n "__fish_use_subcommand" -l continue -d 'Continue execution even if a task exits with an error or non-zero exit code. The default behavior is to bail'
complete -c turbo -n "__fish_use_subcommand" -l go-fallback -d 'Fallback to use Go for task execution'
complete -c turbo -n "__fish_use_subcommand" -l single-package -d 'Run turbo in single-package mode'
complete -c turbo -n "__fish_use_subcommand" -l include-dependencies -d 'Include the dependencies of tasks in execution'
complete -c turbo -n "__fish_use_subcommand" -l no-cache -d 'Avoid saving task results to the cache. Useful for development/watch tasks'
complete -c turbo -n "__fish_use_subcommand" -l [no-]daemon -d 'Force turbo to either use or not use the local daemon. If unset turbo will use the default detection logic'
complete -c turbo -n "__fish_use_subcommand" -l no-daemon
complete -c turbo -n "__fish_use_subcommand" -l no-deps -d 'Exclude dependent task consumers from execution'
complete -c turbo -n "__fish_use_subcommand" -l only -d 'Only executes the tasks specified, does not execute parent tasks'
complete -c turbo -n "__fish_use_subcommand" -l parallel -d 'Execute all tasks in parallel'
complete -c turbo -n "__fish_use_subcommand" -s h -l help -d 'Print help'
complete -c turbo -n "__fish_use_subcommand" -f -a "bin" -d 'Get the path to the Turbo binary'
complete -c turbo -n "__fish_use_subcommand" -f -a "completion" -d 'Generate the autocompletion script for the specified shell'
complete -c turbo -n "__fish_use_subcommand" -f -a "daemon" -d 'Runs the Turborepo background daemon'
complete -c turbo -n "__fish_use_subcommand" -f -a "generate" -d 'Generate a new app / package'
complete -c turbo -n "__fish_use_subcommand" -f -a "telemetry" -d 'Enable or disable anonymous telemetry'
complete -c turbo -n "__fish_use_subcommand" -f -a "info"
complete -c turbo -n "__fish_use_subcommand" -f -a "link" -d 'Link your local directory to a Vercel organization and enable remote caching'
complete -c turbo -n "__fish_use_subcommand" -f -a "login" -d 'Login to your Vercel account'
complete -c turbo -n "__fish_use_subcommand" -f -a "logout" -d 'Logout to your Vercel account'
complete -c turbo -n "__fish_use_subcommand" -f -a "prune" -d 'Prepare a subset of your monorepo'
complete -c turbo -n "__fish_use_subcommand" -f -a "run" -d 'Run tasks across projects in your monorepo'
complete -c turbo -n "__fish_use_subcommand" -f -a "unlink" -d 'Unlink the current directory from your Vercel organization and disable Remote Caching'
complete -c turbo -n "__fish_seen_subcommand_from bin" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from bin" -l cpuprofile -d 'Specify a file to save a cpu profile' -r
complete -c turbo -n "__fish_seen_subcommand_from bin" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_seen_subcommand_from bin" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_seen_subcommand_from bin" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_seen_subcommand_from bin" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_seen_subcommand_from bin" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from bin" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from bin" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_seen_subcommand_from bin" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_seen_subcommand_from bin" -l version
complete -c turbo -n "__fish_seen_subcommand_from bin" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_seen_subcommand_from bin" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_seen_subcommand_from bin" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from bin" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from bin" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_seen_subcommand_from bin" -s v
complete -c turbo -n "__fish_seen_subcommand_from bin" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_seen_subcommand_from bin" -l __test-run
complete -c turbo -n "__fish_seen_subcommand_from bin" -s h -l help -d 'Print help'
complete -c turbo -n "__fish_seen_subcommand_from completion" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from completion" -l cpuprofile -d 'Specify a file to save a cpu profile' -r
complete -c turbo -n "__fish_seen_subcommand_from completion" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_seen_subcommand_from completion" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_seen_subcommand_from completion" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_seen_subcommand_from completion" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_seen_subcommand_from completion" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from completion" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from completion" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_seen_subcommand_from completion" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_seen_subcommand_from completion" -l version
complete -c turbo -n "__fish_seen_subcommand_from completion" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_seen_subcommand_from completion" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_seen_subcommand_from completion" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from completion" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from completion" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_seen_subcommand_from completion" -s v
complete -c turbo -n "__fish_seen_subcommand_from completion" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_seen_subcommand_from completion" -l __test-run
complete -c turbo -n "__fish_seen_subcommand_from completion" -s h -l help -d 'Print help'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -l idle-time -d 'Set the idle timeout for turbod' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -l cpuprofile -d 'Specify a file to save a cpu profile' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -l version
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -s v
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -l __test-run
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -s h -l help -d 'Print help'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -f -a "restart" -d 'Restarts the turbo daemon'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -f -a "start" -d 'Ensures that the turbo daemon is running'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -f -a "status" -d 'Reports the status of the turbo daemon'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -f -a "stop" -d 'Stops the turbo daemon'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and not __fish_seen_subcommand_from restart; and not __fish_seen_subcommand_from start; and not __fish_seen_subcommand_from status; and not __fish_seen_subcommand_from stop; and not __fish_seen_subcommand_from clean" -f -a "clean" -d 'Stops the turbo daemon if it is already running, and removes any stale daemon state'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from restart" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from restart" -l cpuprofile -d 'Specify a file to save a cpu profile' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from restart" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from restart" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from restart" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from restart" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from restart" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from restart" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from restart" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from restart" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from restart" -l version
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from restart" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from restart" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from restart" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from restart" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from restart" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from restart" -s v
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from restart" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from restart" -l __test-run
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from restart" -s h -l help -d 'Print help'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from start" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from start" -l cpuprofile -d 'Specify a file to save a cpu profile' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from start" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from start" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from start" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from start" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from start" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from start" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from start" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from start" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from start" -l version
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from start" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from start" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from start" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from start" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from start" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from start" -s v
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from start" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from start" -l __test-run
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from start" -s h -l help -d 'Print help'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from status" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from status" -l cpuprofile -d 'Specify a file to save a cpu profile' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from status" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from status" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from status" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from status" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from status" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from status" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from status" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from status" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from status" -l json -d 'Pass --json to report status in JSON format'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from status" -l version
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from status" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from status" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from status" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from status" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from status" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from status" -s v
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from status" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from status" -l __test-run
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from status" -s h -l help -d 'Print help'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from stop" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from stop" -l cpuprofile -d 'Specify a file to save a cpu profile' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from stop" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from stop" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from stop" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from stop" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from stop" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from stop" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from stop" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from stop" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from stop" -l version
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from stop" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from stop" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from stop" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from stop" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from stop" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from stop" -s v
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from stop" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from stop" -l __test-run
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from stop" -s h -l help -d 'Print help'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from clean" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from clean" -l cpuprofile -d 'Specify a file to save a cpu profile' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from clean" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from clean" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from clean" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from clean" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from clean" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from clean" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from clean" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from clean" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from clean" -l version
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from clean" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from clean" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from clean" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from clean" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from clean" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from clean" -s v
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from clean" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from clean" -l __test-run
complete -c turbo -n "__fish_seen_subcommand_from daemon; and __fish_seen_subcommand_from clean" -s h -l help -d 'Print help'
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -l tag -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -s c -l config -d 'Generator configuration file' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -s r -l root -d 'The root of your repository (default: directory with root turbo.json)' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -s a -l args -d 'Answers passed directly to generator' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -l cpuprofile -d 'Specify a file to save a cpu profile' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -l version
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -s v
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -l __test-run
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -s h -l help -d 'Print help'
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -f -a "workspace" -d 'Add a new package or app to your project'
complete -c turbo -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from workspace; and not __fish_seen_subcommand_from run" -f -a "run"
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -s n -l name -d 'Name for the new workspace' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -s c -l copy -d 'Generate a workspace using an existing workspace as a template. Can be the name of a local workspace within your monorepo, or a fully qualified GitHub URL with any branch and/or subdirectory' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -s d -l destination -d 'Where the new workspace should be created' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -s t -l type -d 'The type of workspace to create' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -s r -l root -d 'The root of your repository (default: directory with root turbo.json)' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -s p -l example-path -d 'In a rare case, your GitHub URL might contain a branch name with a slash (e.g. bug/fix-1) and the path to the example (e.g. foo/bar). In this case, you must specify the path to the example separately: --example-path foo/bar' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -l cpuprofile -d 'Specify a file to save a cpu profile' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -s b -l empty -d 'Generate an empty workspace'
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -l show-all-dependencies -d 'Do not filter available dependencies by the workspace type'
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -l version
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -s v
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -l __test-run
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from workspace" -s h -l help -d 'Print help'
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from run" -s c -l config -d 'Generator configuration file' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from run" -s r -l root -d 'The root of your repository (default: directory with root turbo.json)' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from run" -s a -l args -d 'Answers passed directly to generator' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from run" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from run" -l cpuprofile -d 'Specify a file to save a cpu profile' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from run" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from run" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from run" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from run" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from run" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from run" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from run" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from run" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from run" -l version
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from run" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from run" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from run" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from run" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from run" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from run" -s v
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from run" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from run" -l __test-run
complete -c turbo -n "__fish_seen_subcommand_from generate; and __fish_seen_subcommand_from run" -s h -l help -d 'Print help'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and not __fish_seen_subcommand_from enable; and not __fish_seen_subcommand_from disable; and not __fish_seen_subcommand_from status" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and not __fish_seen_subcommand_from enable; and not __fish_seen_subcommand_from disable; and not __fish_seen_subcommand_from status" -l cpuprofile -d 'Specify a file to save a cpu profile' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and not __fish_seen_subcommand_from enable; and not __fish_seen_subcommand_from disable; and not __fish_seen_subcommand_from status" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and not __fish_seen_subcommand_from enable; and not __fish_seen_subcommand_from disable; and not __fish_seen_subcommand_from status" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and not __fish_seen_subcommand_from enable; and not __fish_seen_subcommand_from disable; and not __fish_seen_subcommand_from status" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and not __fish_seen_subcommand_from enable; and not __fish_seen_subcommand_from disable; and not __fish_seen_subcommand_from status" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and not __fish_seen_subcommand_from enable; and not __fish_seen_subcommand_from disable; and not __fish_seen_subcommand_from status" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and not __fish_seen_subcommand_from enable; and not __fish_seen_subcommand_from disable; and not __fish_seen_subcommand_from status" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and not __fish_seen_subcommand_from enable; and not __fish_seen_subcommand_from disable; and not __fish_seen_subcommand_from status" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and not __fish_seen_subcommand_from enable; and not __fish_seen_subcommand_from disable; and not __fish_seen_subcommand_from status" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and not __fish_seen_subcommand_from enable; and not __fish_seen_subcommand_from disable; and not __fish_seen_subcommand_from status" -l version
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and not __fish_seen_subcommand_from enable; and not __fish_seen_subcommand_from disable; and not __fish_seen_subcommand_from status" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and not __fish_seen_subcommand_from enable; and not __fish_seen_subcommand_from disable; and not __fish_seen_subcommand_from status" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and not __fish_seen_subcommand_from enable; and not __fish_seen_subcommand_from disable; and not __fish_seen_subcommand_from status" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and not __fish_seen_subcommand_from enable; and not __fish_seen_subcommand_from disable; and not __fish_seen_subcommand_from status" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and not __fish_seen_subcommand_from enable; and not __fish_seen_subcommand_from disable; and not __fish_seen_subcommand_from status" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and not __fish_seen_subcommand_from enable; and not __fish_seen_subcommand_from disable; and not __fish_seen_subcommand_from status" -s v
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and not __fish_seen_subcommand_from enable; and not __fish_seen_subcommand_from disable; and not __fish_seen_subcommand_from status" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and not __fish_seen_subcommand_from enable; and not __fish_seen_subcommand_from disable; and not __fish_seen_subcommand_from status" -l __test-run
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and not __fish_seen_subcommand_from enable; and not __fish_seen_subcommand_from disable; and not __fish_seen_subcommand_from status" -s h -l help -d 'Print help'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and not __fish_seen_subcommand_from enable; and not __fish_seen_subcommand_from disable; and not __fish_seen_subcommand_from status" -f -a "enable" -d 'Enables anonymous telemetry'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and not __fish_seen_subcommand_from enable; and not __fish_seen_subcommand_from disable; and not __fish_seen_subcommand_from status" -f -a "disable" -d 'Disables anonymous telemetry'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and not __fish_seen_subcommand_from enable; and not __fish_seen_subcommand_from disable; and not __fish_seen_subcommand_from status" -f -a "status" -d 'Reports the status of telemetry'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from enable" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from enable" -l cpuprofile -d 'Specify a file to save a cpu profile' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from enable" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from enable" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from enable" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from enable" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from enable" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from enable" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from enable" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from enable" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from enable" -l version
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from enable" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from enable" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from enable" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from enable" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from enable" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from enable" -s v
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from enable" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from enable" -l __test-run
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from enable" -s h -l help -d 'Print help'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from disable" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from disable" -l cpuprofile -d 'Specify a file to save a cpu profile' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from disable" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from disable" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from disable" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from disable" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from disable" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from disable" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from disable" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from disable" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from disable" -l version
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from disable" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from disable" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from disable" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from disable" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from disable" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from disable" -s v
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from disable" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from disable" -l __test-run
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from disable" -s h -l help -d 'Print help'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from status" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from status" -l cpuprofile -d 'Specify a file to save a cpu profile' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from status" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from status" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from status" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from status" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from status" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from status" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from status" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from status" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from status" -l version
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from status" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from status" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from status" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from status" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from status" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from status" -s v
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from status" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from status" -l __test-run
complete -c turbo -n "__fish_seen_subcommand_from telemetry; and __fish_seen_subcommand_from status" -s h -l help -d 'Print help'
complete -c turbo -n "__fish_seen_subcommand_from info" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from info" -l cpuprofile -d 'Specify a file to save a cpu profile' -r
complete -c turbo -n "__fish_seen_subcommand_from info" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_seen_subcommand_from info" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_seen_subcommand_from info" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_seen_subcommand_from info" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_seen_subcommand_from info" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from info" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from info" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_seen_subcommand_from info" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_seen_subcommand_from info" -l json
complete -c turbo -n "__fish_seen_subcommand_from info" -l version
complete -c turbo -n "__fish_seen_subcommand_from info" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_seen_subcommand_from info" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_seen_subcommand_from info" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from info" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from info" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_seen_subcommand_from info" -s v
complete -c turbo -n "__fish_seen_subcommand_from info" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_seen_subcommand_from info" -l __test-run
complete -c turbo -n "__fish_seen_subcommand_from info" -s h -l help -d 'Print help'
complete -c turbo -n "__fish_seen_subcommand_from link" -l target -d 'Specify what should be linked (default "remote cache")' -r -f -a "{remote-cache	'',spaces	''}"
complete -c turbo -n "__fish_seen_subcommand_from link" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from link" -l cpuprofile -d 'Specify a file to save a cpu profile' -r
complete -c turbo -n "__fish_seen_subcommand_from link" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_seen_subcommand_from link" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_seen_subcommand_from link" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_seen_subcommand_from link" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_seen_subcommand_from link" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from link" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from link" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_seen_subcommand_from link" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_seen_subcommand_from link" -l no-gitignore -d 'Do not create or modify .gitignore (default false)'
complete -c turbo -n "__fish_seen_subcommand_from link" -l version
complete -c turbo -n "__fish_seen_subcommand_from link" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_seen_subcommand_from link" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_seen_subcommand_from link" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from link" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from link" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_seen_subcommand_from link" -s v
complete -c turbo -n "__fish_seen_subcommand_from link" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_seen_subcommand_from link" -l __test-run
complete -c turbo -n "__fish_seen_subcommand_from link" -s h -l help -d 'Print help'
complete -c turbo -n "__fish_seen_subcommand_from login" -l sso-team -r
complete -c turbo -n "__fish_seen_subcommand_from login" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from login" -l cpuprofile -d 'Specify a file to save a cpu profile' -r
complete -c turbo -n "__fish_seen_subcommand_from login" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_seen_subcommand_from login" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_seen_subcommand_from login" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_seen_subcommand_from login" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_seen_subcommand_from login" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from login" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from login" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_seen_subcommand_from login" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_seen_subcommand_from login" -l version
complete -c turbo -n "__fish_seen_subcommand_from login" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_seen_subcommand_from login" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_seen_subcommand_from login" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from login" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from login" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_seen_subcommand_from login" -s v
complete -c turbo -n "__fish_seen_subcommand_from login" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_seen_subcommand_from login" -l __test-run
complete -c turbo -n "__fish_seen_subcommand_from login" -s h -l help -d 'Print help'
complete -c turbo -n "__fish_seen_subcommand_from logout" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from logout" -l cpuprofile -d 'Specify a file to save a cpu profile' -r
complete -c turbo -n "__fish_seen_subcommand_from logout" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_seen_subcommand_from logout" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_seen_subcommand_from logout" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_seen_subcommand_from logout" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_seen_subcommand_from logout" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from logout" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from logout" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_seen_subcommand_from logout" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_seen_subcommand_from logout" -l version
complete -c turbo -n "__fish_seen_subcommand_from logout" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_seen_subcommand_from logout" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_seen_subcommand_from logout" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from logout" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from logout" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_seen_subcommand_from logout" -s v
complete -c turbo -n "__fish_seen_subcommand_from logout" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_seen_subcommand_from logout" -l __test-run
complete -c turbo -n "__fish_seen_subcommand_from logout" -s h -l help -d 'Print help'
complete -c turbo -n "__fish_seen_subcommand_from prune" -l scope -r
complete -c turbo -n "__fish_seen_subcommand_from prune" -l out-dir -r
complete -c turbo -n "__fish_seen_subcommand_from prune" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from prune" -l cpuprofile -d 'Specify a file to save a cpu profile' -r
complete -c turbo -n "__fish_seen_subcommand_from prune" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_seen_subcommand_from prune" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_seen_subcommand_from prune" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_seen_subcommand_from prune" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_seen_subcommand_from prune" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from prune" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from prune" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_seen_subcommand_from prune" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_seen_subcommand_from prune" -l docker
complete -c turbo -n "__fish_seen_subcommand_from prune" -l version
complete -c turbo -n "__fish_seen_subcommand_from prune" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_seen_subcommand_from prune" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_seen_subcommand_from prune" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from prune" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from prune" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_seen_subcommand_from prune" -s v
complete -c turbo -n "__fish_seen_subcommand_from prune" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_seen_subcommand_from prune" -l __test-run
complete -c turbo -n "__fish_seen_subcommand_from prune" -s h -l help -d 'Print help'
complete -c turbo -n "__fish_seen_subcommand_from run" -l cache-dir -d 'Override the filesystem cache directory' -r
complete -c turbo -n "__fish_seen_subcommand_from run" -l cache-workers -d 'Set the number of concurrent cache operations (default 10)' -r
complete -c turbo -n "__fish_seen_subcommand_from run" -l concurrency -d 'Limit the concurrency of task execution. Use 1 for serial (i.e. one-at-a-time) execution' -r
complete -c turbo -n "__fish_seen_subcommand_from run" -l dry-run -r -f -a "{text	'',json	''}"
complete -c turbo -n "__fish_seen_subcommand_from run" -s F -l filter -d 'Use the given selector to specify package(s) to act as entry points. The syntax mirrors pnpm\'s syntax, and additional documentation and examples can be found in turbo\'s documentation https://turbo.build/repo/docs/reference/command-line-reference/run#--filter' -r
complete -c turbo -n "__fish_seen_subcommand_from run" -l force -d 'Ignore the existing cache (to force execution)' -r -f -a "{true	'',false	''}"
complete -c turbo -n "__fish_seen_subcommand_from run" -l framework-inference -d 'Specify whether or not to do framework inference for tasks' -r -f -a "{true	'',false	''}"
complete -c turbo -n "__fish_seen_subcommand_from run" -l global-deps -d 'Specify glob of global filesystem dependencies to be hashed. Useful for .env and files' -r
complete -c turbo -n "__fish_seen_subcommand_from run" -l graph -d 'Generate a graph of the task execution and output to a file when a filename is specified (.svg, .png, .jpg, .pdf, .json, .html). Outputs dot graph to stdout when if no filename is provided' -r
complete -c turbo -n "__fish_seen_subcommand_from run" -l env-mode -d 'Environment variable mode. Use "loose" to pass the entire existing environment. Use "strict" to use an allowlist specified in turbo.json. Use "infer" to defer to existence of "passThroughEnv" or "globalPassThroughEnv" in turbo.json. (default infer)' -r -f -a "{infer	'',loose	'',strict	''}"
complete -c turbo -n "__fish_seen_subcommand_from run" -l ignore -d 'Files to ignore when calculating changed files (i.e. --since). Supports globs' -r
complete -c turbo -n "__fish_seen_subcommand_from run" -l output-logs -d 'Set type of process output logging. Use "full" to show all output. Use "hash-only" to show only turbo-computed task hashes. Use "new-only" to show only new output with only hashes for cached tasks. Use "none" to hide process output. (default full)' -r -f -a "{full	'',none	'',hash-only	'',new-only	'',errors-only	''}"
complete -c turbo -n "__fish_seen_subcommand_from run" -l log-order -d 'Set type of task output order. Use "stream" to show output as soon as it is available. Use "grouped" to show output when a command has finished execution. Use "auto" to let turbo decide based on its own heuristics. (default auto)' -r -f -a "{auto	'',stream	'',grouped	''}"
complete -c turbo -n "__fish_seen_subcommand_from run" -l pkg-inference-root -r
complete -c turbo -n "__fish_seen_subcommand_from run" -l profile -d 'File to write turbo\'s performance profile output into. You can load the file up in chrome://tracing to see which parts of your build were slow' -r
complete -c turbo -n "__fish_seen_subcommand_from run" -l anon-profile -d 'File to write turbo\'s performance profile output into. All identifying data omitted from the profile' -r
complete -c turbo -n "__fish_seen_subcommand_from run" -l remote-only -d 'Ignore the local filesystem cache for all tasks. Only allow reading and caching artifacts using the remote cache' -r -f -a "{true	'',false	''}"
complete -c turbo -n "__fish_seen_subcommand_from run" -l remote-cache-read-only -d 'Treat remote cache as read only' -r -f -a "{true	'',false	''}"
complete -c turbo -n "__fish_seen_subcommand_from run" -l scope -d 'Specify package(s) to act as entry points for task execution. Supports globs' -r
complete -c turbo -n "__fish_seen_subcommand_from run" -l since -d 'Limit/Set scope to changed packages since a mergebase. This uses the git diff ${target_branch}... mechanism to identify which packages have changed' -r
complete -c turbo -n "__fish_seen_subcommand_from run" -l summarize -d 'Generate a summary of the turbo run' -r -f -a "{true	'',false	''}"
complete -c turbo -n "__fish_seen_subcommand_from run" -l log-prefix -d 'Use "none" to remove prefixes from task logs. Use "task" to get task id prefixing. Use "auto" to let turbo decide how to prefix the logs based on the execution environment. In most cases this will be the same as "task". Note that tasks running in parallel interleave their logs, so removing prefixes can make it difficult to associate logs with tasks. Use --log-order=grouped to prevent interleaving. (default auto)' -r -f -a "{auto	'',none	'',task	''}"
complete -c turbo -n "__fish_seen_subcommand_from run" -l experimental-space-id -r
complete -c turbo -n "__fish_seen_subcommand_from run" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from run" -l cpuprofile -d 'Specify a file to save a cpu profile' -r
complete -c turbo -n "__fish_seen_subcommand_from run" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_seen_subcommand_from run" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_seen_subcommand_from run" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_seen_subcommand_from run" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_seen_subcommand_from run" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from run" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from run" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_seen_subcommand_from run" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_seen_subcommand_from run" -l continue -d 'Continue execution even if a task exits with an error or non-zero exit code. The default behavior is to bail'
complete -c turbo -n "__fish_seen_subcommand_from run" -l go-fallback -d 'Fallback to use Go for task execution'
complete -c turbo -n "__fish_seen_subcommand_from run" -l single-package -d 'Run turbo in single-package mode'
complete -c turbo -n "__fish_seen_subcommand_from run" -l include-dependencies -d 'Include the dependencies of tasks in execution'
complete -c turbo -n "__fish_seen_subcommand_from run" -l no-cache -d 'Avoid saving task results to the cache. Useful for development/watch tasks'
complete -c turbo -n "__fish_seen_subcommand_from run" -l [no-]daemon -d 'Force turbo to either use or not use the local daemon. If unset turbo will use the default detection logic'
complete -c turbo -n "__fish_seen_subcommand_from run" -l no-daemon
complete -c turbo -n "__fish_seen_subcommand_from run" -l no-deps -d 'Exclude dependent task consumers from execution'
complete -c turbo -n "__fish_seen_subcommand_from run" -l only -d 'Only executes the tasks specified, does not execute parent tasks'
complete -c turbo -n "__fish_seen_subcommand_from run" -l parallel -d 'Execute all tasks in parallel'
complete -c turbo -n "__fish_seen_subcommand_from run" -l version
complete -c turbo -n "__fish_seen_subcommand_from run" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_seen_subcommand_from run" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_seen_subcommand_from run" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from run" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from run" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_seen_subcommand_from run" -s v
complete -c turbo -n "__fish_seen_subcommand_from run" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_seen_subcommand_from run" -l __test-run
complete -c turbo -n "__fish_seen_subcommand_from run" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_seen_subcommand_from unlink" -l target -d 'Specify what should be unlinked (default "remote cache")' -r -f -a "{remote-cache	'',spaces	''}"
complete -c turbo -n "__fish_seen_subcommand_from unlink" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from unlink" -l cpuprofile -d 'Specify a file to save a cpu profile' -r
complete -c turbo -n "__fish_seen_subcommand_from unlink" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_seen_subcommand_from unlink" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_seen_subcommand_from unlink" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_seen_subcommand_from unlink" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_seen_subcommand_from unlink" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from unlink" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_seen_subcommand_from unlink" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_seen_subcommand_from unlink" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_seen_subcommand_from unlink" -l version
complete -c turbo -n "__fish_seen_subcommand_from unlink" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_seen_subcommand_from unlink" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_seen_subcommand_from unlink" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from unlink" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_seen_subcommand_from unlink" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_seen_subcommand_from unlink" -s v
complete -c turbo -n "__fish_seen_subcommand_from unlink" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_seen_subcommand_from unlink" -l __test-run
complete -c turbo -n "__fish_seen_subcommand_from unlink" -s h -l help -d 'Print help'
