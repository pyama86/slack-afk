VERSION=0.0.4
build:
	docker build --platform linux/amd64 -t pyama/away-from-keyboard:$(VERSION)  .
	docker push pyama/away-from-keyboard:$(VERSION)

.PHONY: releasedeps
releasedeps: git-semv

.PHONY: git-semv
git-semv:
ifeq ($(shell uname),Linux)
	which git-semv || (wget https://github.com/linyows/git-semv/releases/download/v1.2.0/git-semv_linux_x86_64.tar.gz && tar zxvf git-semv_linux_x86_64.tar.gz && sudo mv git-semv /usr/bin/)
else
	which git-semv > /dev/null || brew tap linyows/git-semv
	which git-semv > /dev/null || brew install git-semv
endif
