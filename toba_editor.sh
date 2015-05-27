#!/bin/bash

if [ -z "$TOBA_ID_DESARROLLADOR" ]; then
    echo "Notice: Se utiliza el id_desarrollador default (0)";
    TOBA_ID_DESARROLLADOR=0;
fi

if [ -z "$TOBA_PASS" ]; then
    echo "Warning: Se utiliza el password default (toba)";
    TOBA_PASS=toba;
fi

if [ -z "$TOBA_NOMBRE_INSTALACION" ]; then
	echo "Notice: Se utiliza el nombre de instalacion por default (Toba Editor)";	
    TOBA_NOMBRE_INSTALACION="Toba Editor";
fi

HOME_TOBA=/var/local/toba
export TOBA_INSTALACION_DIR=${HOME_TOBA}/docker-data/instalacion
if [ -z "$(ls -A "$TOBA_INSTALACION_DIR")" ]; then
    echo -n postgres > /tmp/clave_pg;
    echo -n ${TOBA_PASS} > /tmp/clave_toba;
    ${HOME_TOBA}/bin/instalar -d ${TOBA_ID_DESARROLLADOR} -t 0 -h pg -p 5432 -u postgres -b toba -c /tmp/clave_pg -k /tmp/clave_toba -n ${TOBA_NOMBRE_INSTALACION}
    
    #Permite a Toba guardar los logs
	chown -R www-data ${TOBA_INSTALACION_DIR}/i__desarrollo

    #Permite al usuario HOST editar los archivos
	chmod -R a+w ${TOBA_INSTALACION_DIR}
fi

ln -s ${TOBA_INSTALACION_DIR}/toba.conf /etc/apache2/sites-enabled/toba.conf;

#Se deja el ID del container dentro de la configuración de toba, para luego poder usarlo desde el Host
DOCKER_CONTAINER_ID=`cat /proc/self/cgroup | grep -o  -e "docker-.*.scope" | head -n 1 | sed "s/docker-\(.*\).scope/\\1/"`
echo "TOBA_DOCKER_ID=$DOCKER_CONTAINER_ID" > ${TOBA_INSTALACION_DIR}/toba_docker.env

#Cada vez que se loguea por bash al container, carga las variables de entorno toba
echo ". ${HOME_TOBA}/bin/entorno_toba_trunk.sh" > /root/.bashrc
echo "export TERM=xterm;" >> /root/.bashrc
echo "cd ${HOME_TOBA};" >> /root/.bashrc

