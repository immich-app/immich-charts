{{- define "debug.var_dump" -}}
{{- . | toPrettyJson | printf "\nThe JSON output of the dumped var is: \n%s" | fail }}
{{- end -}}