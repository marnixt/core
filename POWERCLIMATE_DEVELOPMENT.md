# PowerClimate HACS Integration Development Setup

## Overview
Your PowerClimate integration is now set up for development within the Home Assistant Core workspace. This setup allows you to:

- Develop and test your custom component within the HA Core environment
- Sync changes back to your GitHub repository
- Use Home Assistant's development tools and testing framework

## Directory Structure

```
/workspaces/
├── core/                                    # Home Assistant Core
│   ├── config/
│   │   └── custom_components/
│   │       └── powerclimate/                # Symlink to your integration
│   ├── tests/components/powerclimate/       # Integration tests
│   └── powerclimate_sync.sh               # Git sync script
└── PowerClimate/                           # Your HACS repository
    └── config/custom_components/powerclimate/  # Actual integration files
```

## Development Workflow

### 1. Making Changes
Edit files in either location (they're symlinked):
- `/workspaces/core/config/custom_components/powerclimate/` (via symlink)
- `/workspaces/PowerClimate/config/custom_components/powerclimate/` (original)

### 2. Testing Changes
```bash
# Method 1: Use the sync script
./powerclimate_sync.sh restart-ha

# Method 2: Manual restart
cd /workspaces/core
python -m homeassistant -c ./config --debug
```

### Dummy climate entity (for quick testing)

The repository now contains a minimal dummy `climate` platform that exposes a
`PowerClimate Dummy` entity. Use this to verify that the integration loads and
that services like `climate.set_temperature` and `climate.set_hvac_mode` work.

Steps to test:

1. Restart Home Assistant using the sync script or manual command above.
2. Open Developer Tools → States and search for `climate.powerclimate_dummy` or
    look for an entity named "PowerClimate Dummy".
3. Use Developer Tools → Services to call `climate.set_temperature` with
    the target entity and a `temperature` value to verify state updates.

Example service call payload:

```json
{ "entity_id": "climate.powerclimate_dummy", "temperature": 23 }
```

If the entity is present and responds, your integration is loaded correctly and
can be used as a base for adding real device communication.

### 3. Running Tests
```bash
# Run specific integration tests
cd /workspaces/core
python -m pytest tests/components/powerclimate/ -v

# Run with coverage
python -m pytest tests/components/powerclimate/ --cov=homeassistant.components.powerclimate --cov-report=term-missing
```

### 4. Committing and Syncing Changes

Using the sync script:
```bash
# Check status
./powerclimate_sync.sh status

# View changes
./powerclimate_sync.sh diff

# Commit changes
./powerclimate_sync.sh commit "Your commit message"

# Push to GitHub
./powerclimate_sync.sh push

# Pull latest from GitHub
./powerclimate_sync.sh pull
```

Manual git workflow:
```bash
cd /workspaces/PowerClimate
git add config/custom_components/powerclimate/
git commit -m "Your commit message"
git push origin master
```

## Current Integration Structure

Your PowerClimate integration includes:
- `__init__.py` - Integration setup and entry point
- `manifest.json` - Integration metadata (✅ updated with correct GitHub URL)
- `config_flow.py` - Configuration flow for UI setup
- `const.py` - Constants and configuration
- `sensor.py` - Sensor platform implementation
- `number.py` - Number entity platform
- `strings.json` - UI text and translations

## HACS Compatibility

Your integration is structured correctly for HACS:
- ✅ Proper manifest.json with required fields
- ✅ Config flow support (`"config_flow": true`)
- ✅ Correct directory structure
- ✅ GitHub repository URL configured

## Next Steps

1. **Add Integration Type to Manifest**: Consider adding `"integration_type"` to manifest.json:
   ```json
   "integration_type": "device"  // or "service", "hub", etc.
   ```

2. **Create Tests**: Add comprehensive tests in `/workspaces/core/tests/components/powerclimate/`

3. **Documentation**: Update your GitHub repository's README.md with installation and usage instructions

4. **HACS Submission**: When ready, submit to HACS following their guidelines

## Git Status
- ✅ Repository cloned and configured
- ✅ Symlink created for seamless development
- ✅ Manifest.json documentation URL fixed and committed
- ✅ Test directory structure created
- ✅ Sync workflow established

## Useful Commands

```bash
# Sync script help
./powerclimate_sync.sh

# Check Home Assistant logs
tail -f /workspaces/core/config/home-assistant.log

# Validate integration
cd /workspaces/core
python -m script.hassfest --integration-path config/custom_components/powerclimate

# Run linting
pre-commit run --files config/custom_components/powerclimate/*
```

Your PowerClimate integration is now ready for development! 🚀
