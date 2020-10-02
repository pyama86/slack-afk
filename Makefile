VERSION=0.0.2
build:
	docker build -t pyama/away-from-keyboard:$(VERSION)  .
	docker push pyama/away-from-keyboard:$(VERSION)
