
#
# Configuration for balena storage
#

BALENA_STORAGE ?= "aufs"

python do_kernel_resin_aufs_fetch_and_unpack() {

    import collections, os.path, re
    from bb.fetch2.git import Git

    kernelsource = d.getVar('S', True)

    # get the kernel version from the top Makefile in the kernel source tree
    topmakefile = kernelsource + "/Makefile"
    with open(topmakefile, 'r') as makefile:
        lines = makefile.readlines()

    kernelversion = ""
    for s in lines:
        m = re.match("VERSION = (\d+)", s)
        if m:
            kernelversion_major = m.group(1)
            kernelversion = kernelversion + m.group(1)
        m = re.match("PATCHLEVEL = (\d+)", s)
        if m:
            kernelversion = kernelversion + '.' + m.group(1)
        m = re.match("SUBLEVEL = (\d+)", s)
        if m:
            kernelversion = kernelversion + '.' + m.group(1)
        m = re.match("EXTRAVERSION = (\d+)", s)
        if m:
            kernelversion = kernelversion + '.' + m.group(1)

    balena_storage = d.getVar('BALENA_STORAGE', True)
    bb.note("Kernel will be configured for " + balena_storage + " balena storage driver.")

    # If overlay2, we assume support in the kernel source so no need for extra
    # patches
    if balena_storage == "overlay2":
        if int(kernelversion_major) < 4:
            bb.fatal("overlay2 is only available from kernel version 4.0. Can't use overlay2 as BALENA_STORAGE.")
        return

    # Everything from here is for aufs
    if os.path.isdir(kernelsource + "/fs/aufs"):
        bb.note("The kernel source tree has the fs/aufs directory. Will not fetch and unpack aufs patches.")
        return

    # define an ordered dictionary with aufs branch names as keys and branch revisions as values
    aufsdict = collections.OrderedDict([
        ('3.0', 'aa3d7447003abd5e3c437de52d8da2e6203390ac'),
        ('3.1', '269a613efab1718fd587c2bfc945d095b57f56e2'),
        ('3.2', '5809bf47aeb6e8257691287f9a218660c110acc5'),
        ('3.2.x', '16af2a5afdfd14bc482963942b2e657a032da43d'),
        ('3.3', 'df60b373c5f6c22835fdb8521b12973e9d6e06df'),
        ('3.4', 'bfbe10165cbfc0cd7b1d7e9c878f1a3f2b6872f1'),
        ('3.5', '3e310a136e71bb284a959d95c77f5b7af132280b'),
        ('3.6', '82d56105d0bdbdf5959b16f788fed4f6a530373f'),
        ('3.7', '27b5f7469fe5259aa489e92fdb6d88900ec8c0a4'),
        ('3.8', 'e98c69e26250b411e51cc92bf73df2f0829d0759'),
        ('3.9', 'f88513f985e153aaf3e2950622c2a2329c3c3f8f'),
        ('3.10', '4a8ee1833947c5aba704bf09fad612f4c4ecd827'),
        ('3.10.x', '3ec542bfe6854491bceb77b40c46f3b63849445a'),
        ('3.11', '35fd8e89d9cbd3b665dd11c3ae901ac52b07bcbb'),
        ('3.12', 'fcc197ae3a575b6f1b2aa1e51fe250eaadd4292b'),
        ('3.12.x', '74a2fd46ecfeb9d520e50779734a473037924831'),
        ('3.12.31+', 'bc1683ef045db170785c86eeebe57798445af63c'),
        ('3.13', 'b8ca8d15cf8e635d310acab5e571e31399a842b2'),
        ('3.14', 'b279b0bb265eb0c71c0420becd127c90f09b0003'),
        ('3.14.21+', 'aea8b249e0a369981f2b2c9a58f5aaf200e31594'),
        ('3.14.40+', '6eb622e3346262bd20b05458c371b864577b8c27'),
        ('3.15', '19702ee73cdc4a102593969537938f3183d4b841'),
        ('3.16', 'cb287d372de85fad6a15afa198d7526383037381'),
        ('3.17', 'a511fd5b5b4a311c906e200ef8abc42d1387b94d'),
        ('3.18', 'b5a25205ee21187e20e1d998f98763d09f442c26'),
        ('3.18.1+', 'cb74b62417010b75273fa1e1ee89d2a4782a728f'),
        ('3.18.25+', '0591c3182066555d46564404a29786232d49e977'),
        ('3.19', '2a2a3ee407810b4a3e19c3d5cfdb7f371d5df835'),
        ('4.0', 'f3daf663294ae51cde1105450705a83d7f0abf84'),
        ('4.1', '779216b4d28c295a6f52787dc35962e6dedcdc8c'),
        ('4.1.13+', '5757557b36dc5e875e93dbe299e75dd331126d98'),
        ('4.2', '7696ae969ebcef1b7a74d0d0aeae8857dfb972c1'),
        ('4.3', '09faae00f970d044ccd90ea8cc9a34545b3ac24d'),
        ('4.4', '7b00655846641e84c87f9af94985f48e4bb0f2df'),
        ('4.5', '655770239032bc4dec1e591016e1a3a5307c9f6c'),
        ('4.6', '058f6e23530e4b38f60725537ad151098ee74437'),
        ('4.7', '0228f4bae07367afbcccc7b1c98ec438c35fb60e'),
        ('4.8', 'f1590cdde901ad19fa9800b1a35b557270f29fc0'),
        ('4.9', '34be418bd4f0bb069e3971c76f5a8d8a6038558a'),
        ('4.9.9+', '71d20f2f8e0d26779645b1a436d9c7a6f87911a4'),
        ('4.9.94+', '600b5b31643556b07e9782efb73f3b0092e6a58c'),
        ('4.10', 'aa5ef5e7a628817b6c2c89acddfc7976bb758bb6'),
        ('4.11.7+', '017c55ba5613570d44f63c99cfd39c01867dc826'),
        ('4.12', '31266c01bd88e0053f53f4580adcca03175947b2'),
        ('4.13', '78cbc7ffc120b21092a984808865f226764eed3b'),
        ('4.14', '4c216b1d3bbf21036bc6e411dbaddc5ee8796e0f'),
        ('4.14.56+', 'afd6e70189fae85fe979cb545c0521aa9e1089d3'),
        ('4.14.73+', '8023d982d4cda2d013bac2198fedf5d6b725e293'),
        ('4.15', '131620712a70671a8785fd286134732a7d625efe'),
        ('4.16', '3b2c02d1fbab48b88a32b5727663570987e55072'),
        ('4.17', '3816135ec95c99eecbbf24b1763447effbdd6c46'),
        ('4.18', '49d3207c61c0d666281def82223a962934154205'),
        ('4.18.11+', 'd0ca3f45ce8ef07678011638172a34ace1cdb8a1'),
        ('4.19', 'fed453019cc702a1cacb2322584686610ea927ab'),
        ('4.19.17+', '07f8ca2b7140807f61e0a3fdc666e8748c7a34b7'),
        ('4.20', 'caa38687d80a9aad141882d2a9f1db8cd2612d2d'),
        ('4.20.4+', 'a55d8ab0451105ffc86078e4ea1bf2df2c0a4f12'),
        ('5.0', '25f304c2c8c866b551ba7dc0c26b8fc1bbac95fa'),
        ('5.1', 'd051ff358d1072d71103b076ca2d7d163a17a3f8'),
        ('5.2', '45f6f8eb62d2208316ad09bf9cce7d88537270f4'),
        ('5.2.5+', '40a8029ab232f2e03c7a9939800f2507308f5b38'),
        ('5.3', '26428f642dce5b1c1455fa73ac77c3b51bafdd85'),
        ('5.3.16', '28e5d4ec9104b44ae72da47218e60f9d3d5cc11b'),
        ('5.4', 'caffea77e5b1141c844a8a5fce066bfba42736cd'),
        ('5.4.3', '646ec02273c72547077e2e19e7a15c0e3a1f4951'),
        ('5.5', '9ba4e2c61e93f74711fe858f49bd255f5d829fb4'),
        ('5.6', '2ab5ec25767c8acf116ef7f8d3a896d0c357593e'),
        ('5.7', 'ac34d21c4044d0232f5ff74e5543e3793071c671'),
    ])


    # match with the correct aufs branch for our kernel version
    # from the aufs git repo README file:

    # 'For (an unreleased) example:
    # If you are using "linux-4.10" and the "aufs4.10" branch
    # does not exist in aufs-util repository, then "aufs4.9", "aufs4.8"
    # or something numerically smaller is the branch for your kernel.'

    for key, value in reversed(list(aufsdict.items())) :
        if key.split('+')[0] is kernelversion:
            aufsbranch = key
            break

        keylen = len(key.split('+')[0].split('.'))
        if int(key.split('+')[0].split('.')[0]) > int(kernelversion.split('.')[0]):
            continue
        elif int(key.split('+')[0].split('.')[0]) < int(kernelversion.split('.')[0]):
            aufsbranch = key
            break

        if int(key.split('+')[0].split('.')[1]) > int(kernelversion.split('.')[1]):
            continue
        elif int(key.split('+')[0].split('.')[1]) < int(kernelversion.split('.')[1]):
            aufsbranch = key
            break

        if keylen is 3:
            if int(key.split('+')[0].split('.')[2][:-1] + '0') <= int(kernelversion.split('.')[2]):
                aufsbranch = key
                break
        else:
            aufsbranch = key
            break

    if kernelversion.split('.')[0] is '3':
        srcuri = "git://git.code.sf.net/p/aufs/aufs3-standalone.git;branch=aufs%s;name=aufs;destsuffix=aufs_standalone" % aufsbranch
    elif kernelversion.split('.')[0] is '4':
        srcuri = "git://github.com/sfjro/aufs4-standalone.git;branch=aufs%s;name=aufs;destsuffix=aufs_standalone" % aufsbranch
    elif kernelversion.split('.')[0] is '5':
        srcuri = "git://github.com/sfjro/aufs5-standalone.git;branch=aufs%s;name=aufs;destsuffix=aufs_standalone" % aufsbranch

    d.setVar('SRCREV_aufs', aufsdict[aufsbranch])
    aufsgit = Git()
    urldata = bb.fetch.FetchData(srcuri, d)
    aufsgit.download(urldata, d)
    aufsgit.unpack(urldata, d.getVar('WORKDIR', True), d)
}

# add our task to task queue - we need the kernel version (so we need to have the sources unpacked and patched) in order to know what aufs patches version we fetch and unpack
addtask kernel_resin_aufs_fetch_and_unpack after do_patch before do_configure
kernel_resin_aufs_fetch_and_unpack[vardeps] += "BALENA_STORAGE"

# copy needed aufs files and apply aufs patches
apply_aufs_patches () {
    # bail out if it looks like the kernel source tree already has the fs/aufs directory
    if [ -d ${S}/fs/aufs ] || [ "${BALENA_STORAGE}" != "aufs" ]; then
        exit
    fi
    cp -r ${WORKDIR}/aufs_standalone/Documentation ${WORKDIR}/aufs_standalone/fs ${S}
    cp ${WORKDIR}/aufs_standalone/include/uapi/linux/aufs_type.h ${S}/include/uapi/linux/
    cd ${S}
    if [ -d "${S}/.git" ]; then
        PATCH_CMD="git apply -3"
    else
        PATCH_CMD="patch -p1"
    fi
    $PATCH_CMD < `find ${WORKDIR}/aufs_standalone/ -name 'aufs*-kbuild.patch'`
    $PATCH_CMD < `find ${WORKDIR}/aufs_standalone/ -name 'aufs*-base.patch'`
    $PATCH_CMD < `find ${WORKDIR}/aufs_standalone/ -name 'aufs*-mmap.patch'`
}
do_kernel_resin_aufs_fetch_and_unpack[postfuncs] += "apply_aufs_patches"


# copy to deploy dir latest .config and Module.symvers (after kernel modules have been built)
do_deploy_append () {
    install -m 0644 ${D}/boot/Module.symvers-* ${DEPLOYDIR}/Module.symvers
    install -m 0644 ${D}/boot/config-* ${DEPLOYDIR}/.config
}
