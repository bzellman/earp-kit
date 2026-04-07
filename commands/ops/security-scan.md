---
description: Security audit for code changes
---

# Security Scan

Perform security analysis on recent code changes in the <YOUR_APP> project.

## Security Checks:

### Authentication & Authorization
- Token validation implementation
- Session management
- Logout procedures
- Permission checks

### Data Protection  
- Sensitive data handling
- Encryption usage
- PII protection
- Storage security

### API Security
- Input validation
- SQL injection prevention
- XSS prevention
- Rate limiting

### Secret Management
- Hardcoded secrets
- Key Vault usage
- Config security
- Certificate handling

## Scan Commands:
```bash
# Check for secrets in code
!grep -r "api[_-]?key\|secret\|password" --include="*.swift" --include="*.cs" . | grep -v ".md" | head -20

# Review auth implementations
!grep -r "ValidateToken\|Authorization" Infrastructure/<YOUR_API_PROJECT>/Functions/

# Check HTTPS enforcement
!grep -r "http://" --include="*.swift" --include="*.cs" . | grep -v "https://"
```

## Security Report:
- Vulnerabilities found
- Risk assessment
- Remediation steps
- Best practice recommendations

## Focus area: $ARGUMENTS