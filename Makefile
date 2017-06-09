SOURCES_PATH=src
SOURCES= $(SOURCES_PATH)/def.h \
				 $(SOURCES_PATH)/vhd2vl.l \
				 $(SOURCES_PATH)/vhd2vl.y

src/vhd2vl: $(SOURCES) 
	make -C $(SOURCES_PATH)

clean:
	make -C $(SOURCES_PATH) clean

install: src/vhd2vl
	install $< /usr/bin/

uninstall: /usr/bin/vhd2vl
	-rm $<
