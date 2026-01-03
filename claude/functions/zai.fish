function zai --description "Wrapper for claude that uses z.ai API"
    # Verify ZAI_API_KEY is set
    if not set -q ZAI_API_KEY; or test -z "$ZAI_API_KEY"
        echo "Error: ZAI_API_KEY is not set" >&2
        return 1
    end

    # Set z.ai API configuration and call claude
    set -lx ANTHROPIC_AUTH_TOKEN $ZAI_API_KEY
    set -lx ANTHROPIC_BASE_URL "https://api.z.ai/api/anthropic"
    set -lx API_TIMEOUT_MS 3000000
    set -lx ANTHROPIC_DEFAULT_OPUS_MODEL "GLM-4.7"
    set -lx ANTHROPIC_DEFAULT_SONNET_MODEL "GLM-4.7"
    set -lx ANTHROPIC_DEFAULT_HAIKU_MODEL "GLM-4.5-Air"

    claude $argv
end
