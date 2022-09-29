VERSION=0.0.4
build:
	docker build --platform linux/amd64 -t pyama/away-from-keyboard:$(VERSION)  .
	docker push pyama/away-from-keyboard:$(VERSION)
