# VMW bash functions - available in all VMs
# Mounted at ~/host/functions.sh and sourced from .bashrc

# zai - Wrapper for claude that uses z.ai API
zai() {
    if [ -z "$ZAI_API_KEY" ]; then
        echo "Error: ZAI_API_KEY is not set" >&2
        return 1
    fi

    ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY" \
    ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic" \
    API_TIMEOUT_MS=3000000 \
    ANTHROPIC_DEFAULT_OPUS_MODEL="GLM-4.7" \
    ANTHROPIC_DEFAULT_SONNET_MODEL="GLM-4.7" \
    ANTHROPIC_DEFAULT_HAIKU_MODEL="GLM-4.5-Air" \
    claude "$@"
}
