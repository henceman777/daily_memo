FROM busybox
LABEL manitainer="Max <jinmeng260@gmail.com>" app="httpd"

ENV WEB_DOC_ROOT="/data/web/html/"

RUN mkdir -p $WEB_DOC_ROOT && \
	echo '<h1>BusyBox httpd by Max.</h1>' > ${WEB_DOC_ROOT}/index.html

#SHELL子进程方式运行
#CMD /bin/httpd -f -h ${WEB_DOC_ROOT}

#the syntas won't expand the variable
CMD ["/bin/httpd","-f","-h ${WEB_DOC_ROOT}"]
#CMD ["/bin/sh","-c","/bin/httpd","-f","-h ${WEB_DOC_ROOT}"]
#CMD ["/bin/sh","-c","/bin/httpd","-f","-h /data/web/html/"]
#ENTRYPOINT /bin/httpd -f -h ${WEB_DOC_ROOT}
ENTRYPOINT ["/bin/sh", "-c"]
