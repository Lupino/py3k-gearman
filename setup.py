try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

from distutils.extension import Extension

from Cython.Distutils import build_ext
gearman_ext = Extension("gearman", [
    "src/gearman.pyx",
    "src/utils.c"
])

setup(
    name='gearman',
    version='0.0.2',
    description='warpper libgearman for python3',
    author='Li Meng Jun',
    author_email='lmjubuntu@gmail.com',
    url='http://lupino.me',
    ext_modules=[gearman_ext],
    cmdclass={'build_ext': build_ext},
)
