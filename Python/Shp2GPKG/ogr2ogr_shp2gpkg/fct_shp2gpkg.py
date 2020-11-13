import subprocess
import logging
from pathlib import Path


logging.basicConfig()
logger = logging.getLogger()



FILE_EXT_SHP = 'shp'
FILE_EXT_GPKG = 'gpkg'


def convert_file(ori_root_dir, final_root_dir, ori_file, final_file, format="GPKG"):
    """
        Fonction qui lance la converti un fichier en gpkg

        :params:ori_root_dir : répertoire racine d'où est lancée l'analyse
        :params:final_root_dir : répertoire racine de stockage des gpkg
        :params:ori_file : fichier à convertir
        :params:final_file : fichier final gpkg
        
    """
    # Test file
    orig = Path(ori_root_dir, ori_file) 
    if not orig.is_file():
        raise FileNotFoundError

    # Test if output dir exists if not create
    dest = Path(final_root_dir, str(ori_file.relative_to(ori_root_dir).parent), str(final_file.name))

    if not dest.parent.is_dir():
        dest.parent.mkdir(parents=True, exist_ok=True)

    
    # Test if not cpg specify IS-8859-1
    # TODO TEST file encoding
    conv = ""
    if not orig.with_suffix("." + "cpg").is_file():
        conv += "--config SHAPE_ENCODING ISO-8859-1"
    ogr_cmd = f"ogr2ogr -overwrite -f {format} {conv} {str(dest)} {str(orig)}" 

    logger.info("Convert file {} to {}".format(str(orig), str(dest))) 

    try:
        subprocess.check_output([x for x in ogr_cmd.split(" ") if x])
    except Exception as e:
        logger.error("Convert file {}".format(str(e))) 
        pass


def process_file(file_path, root_dir, destination_dir):
    """
        Fonction qui lance la conversion d'un fichier en gpkg

        :params:file_path : Fichier à convertir
        :params:root_dir : répertoire racine à analyser
        :params:destination_dir : répertoire où seront créer les gpkg
        
    """
    logger.info("Process file {}".format(str(file_path)))
    
    ext = file_path.suffix

    if not file_path.parent.is_dir():
        return False

    if not ext[1::] == FILE_EXT_SHP:
        logger.info("{} not a shapefile".format(str(file_path)))
        return False

    convert_file(
        ori_root_dir=root_dir, 
        final_root_dir=destination_dir, 
        ori_file=file_path,
        final_file=file_path.with_suffix("." + FILE_EXT_GPKG)
    )

    return True


def browse_and_convert_dir(root_dir, destination_dir, exclude_dir):
    """
        Fonction qui parcours récursivement un dossier
            pour convertir l'ensemble des shp en gpkg

        :params:root_dir : répertoire racine à analyser
        :params:destination_dir : répertoire où seront créer les gpkg
        :params: exclude_dir : liste des répertoires à exclure de la conversion

    """
    root_path = Path(root_dir)
    if not root_path.is_dir():
        raise OSError("{} is not a dir".format(root_dir))
    [
        process_file(path, root_path, destination_dir)
        for path in root_path.glob('**/*.shp')
        if not any((True for x in path.parts if x in exclude_dir))
    ]




# cpg, dbf, prj, shp, shx