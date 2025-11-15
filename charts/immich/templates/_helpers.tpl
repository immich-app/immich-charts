{{- define "valkey.secretName" -}}
    {{- if .Values.immich.valkey.auth.existingSecret }}{{ .Values.immich.valkey.auth.existingSecret }}{{ else }}{{ printf "%s-valkey-auth" .Release.Name }}{{ end }}
{{- end -}}

{{- define "valkey.password" -}}
    {{- $secretName := include "valkey.secretName" .  -}}
    {{- $secret := lookup "v1" "Secret" .Release.Namespace $secretName -}}
    {{- if .Values.immich.valkey.auth.existingSecret -}}
        {{- if not $secret -}}
            {{- fail (printf "existing secret %s not found in namespace %s" $secretName .Release.Namespace) -}}
        {{- else if not $secret.data.REDIS_PASSWORD -}}
            {{- fail (printf "existing secret %s found but data.REDIS_PASSWORD is missing or empty" $secretName) -}}
        {{- end -}}
    {{- end -}}
    {{- if $secret -}}
        {{- $secret.data.REDIS_PASSWORD | b64dec -}}
    {{- else -}}
        {{- randAlphaNum 40 -}}
    {{- end -}}
{{- end -}}

{{- define "valkey.secretChecksum" -}}
    {{- $password := include "valkey.password" . -}}
    {{- $data := dict "REDIS_PASSWORD" ($password | b64enc) -}}
    {{- $data | toJson | sha256sum -}}
{{- end -}}
