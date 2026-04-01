.PHONY: git

git:
	@DATE=$$(date +"%Y-%m-%d %H:%M:%S"); \
	git add -A && \
	git diff --cached --quiet || git commit -m "auto: $$DATE"; \
	git push || true
