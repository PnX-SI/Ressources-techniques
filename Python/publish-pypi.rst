Publier un paquet sur Pypi
==========================

- Générer l'archive et le build (.tar.gz) et le fichier de distrib (.whl) :

::
    
    # Depuis la racine du répertoire où se situe le fichier setup.py
    python3 setup.py sdist bdist_wheel

- Installer twine (utilitaire de publication de paquet) :

::

    python3 -m pip install --user --upgrade twine


- Publier le paquet en renseignant ses identifiants PyPi :

::

    # Sur le dépôt de test
    python3 -m twine upload --repository-url https://test.pypi.org/legacy/ dist/*
    # Sur le dépôt principal
    python3 -m twine upload dist/*


- Installer le paquet :

::
    
    # Depuis le dépot de test
    pip install --index-url https://test.pypi.org/simple/ <nom_de_la_lib>
    # Depuis le dépot principal
    pip install  <nom_de_la_lib>
