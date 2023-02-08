# -*- coding: utf-8 -*-

# (C) Copyright 2018- ECMWF.

# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation
# nor does it submit to any jurisdiction.


import h5py
import numpy as np

from pathlib import Path
from collections import OrderedDict


NCLV = 5      # number of microphysics variables


def load_input_fields(path, transpose=False):
    """
    """
    fields = OrderedDict()

    argnames = [
        'PT', 'PQ',
        'TENDENCY_TMP_T', 'TENDENCY_TMP_Q', 'TENDENCY_TMP_A', 'TENDENCY_TMP_CLD',
        'PVFA', 'PVFL', 'PVFI', 'PDYNA', 'PDYNL', 'PDYNI', 'PHRSW',
        'PHRLW', 'PVERVEL', 'PAP', 'PAPH', 'PLSM', 'LDCUM', 'KTYPE',
        'PLU', 'PLUDE', 'PSNDE', 'PMFU', 'PMFD', 'PA', 'PCLV',
        'PSUPSAT', 'PLCRIT_AER', 'PICRIT_AER', 'PRE_ICE', 'PCCN', 'PNICE'
    ]

    with h5py.File(path, 'r') as f:
        fields['KLON'] = f['KLON'][0]
        fields['KLEV'] = f['KLEV'][0]
        fields['PTSPHY'] = f['PTSPHY'][0]

        klon = fields['KLON']
        klev = fields['KLEV']

        for argname in argnames:
            fields[argname] = np.ascontiguousarray(f[argname])

        fields['TENDENCY_LOC_A'] = np.ndarray(order="C", shape=(klev, klon))
        fields['TENDENCY_LOC_T'] = np.ndarray(order="C", shape=(klev, klon))
        fields['TENDENCY_LOC_Q'] = np.ndarray(order="C", shape=(klev, klon))
        fields['TENDENCY_LOC_CLD'] = np.ndarray(order="C", shape=(NCLV, klev, klon))
        fields['PCOVPTOT'] = np.ndarray(order="C", shape=(klev, klon))
        fields['PRAINFRAC_TOPRFZ'] = np.ndarray(order="C", shape=(klon,))

        fields['PFSQLF'] = np.ndarray(order="C", shape=(klev+1, klon))
        fields['PFSQIF'] = np.ndarray(order="C", shape=(klev+1, klon))
        fields['PFCQNNG'] = np.ndarray(order="C", shape=(klev+1, klon))
        fields['PFCQLNG'] = np.ndarray(order="C", shape=(klev+1, klon))
        fields['PFSQRF'] = np.ndarray(order="C", shape=(klev+1, klon))
        fields['PFSQSF'] = np.ndarray(order="C", shape=(klev+1, klon))
        fields['PFCQRNG'] = np.ndarray(order="C", shape=(klev+1, klon))
        fields['PFCQSNG'] = np.ndarray(order="C", shape=(klev+1, klon))
        fields['PFSQLTUR'] = np.ndarray(order="C", shape=(klev+1, klon))
        fields['PFSQITUR'] = np.ndarray(order="C", shape=(klev+1, klon))
        fields['PFPLSL'] = np.ndarray(order="C", shape=(klev+1, klon))
        fields['PFPLSN'] = np.ndarray(order="C", shape=(klev+1, klon))
        fields['PFHPSL'] = np.ndarray(order="C", shape=(klev+1, klon))
        fields['PFHPSN'] = np.ndarray(order="C", shape=(klev+1, klon)) 

    return fields


def load_input_parameters(path):
    class TECLDP:
        pass
    yrecldp = TECLDP()

    class TEPHLI:
        pass
    yrephli = TEPHLI()

    class TMCST:
        pass
    yrmcst = TMCST()

    class TETHF:
        pass
    yrethf = TETHF()

    class TECLD:
        pass
    yrecld = TECLD()

    with h5py.File(path, 'r') as f:
        tecldp_keys = [k for k in f.keys() if 'YRECLDP' in k]
        for k in tecldp_keys:
            attrkey = k.replace('YRECLDP_', '').lower()
            setattr(yrecldp, attrkey, f[k][0])
        tephli_keys = [k for k in f.keys() if 'YREPHLI' in k]
        for k in tephli_keys:
            attrkey = k.replace('YREPHLI_', '').lower()
            setattr(yrephli, attrkey, f[k][0])

        yrmcst.rg = f['RG'][0]
        yrmcst.rd = f['RD'][0]
        yrmcst.rcpd = f['RCPD'][0]
        yrmcst.retv = f['RETV'][0]
        yrmcst.rlvtt = f['RLVTT'][0]
        yrmcst.rlstt = f['RLSTT'][0]
        yrmcst.rlmlt = f['RLMLT'][0]
        yrmcst.rtt = f['RTT'][0]
        yrmcst.rv = f['RV'][0]

        yrethf.r2es = f['R2ES'][0]
        yrethf.r3les = f['R3LES'][0]
        yrethf.r3ies = f['R3IES'][0]
        yrethf.r4les = f['R4LES'][0]
        yrethf.r4ies = f['R4IES'][0]
        yrethf.r5les = f['R5LES'][0]
        yrethf.r5ies = f['R5IES'][0]
        yrethf.r5alvcp = f['R5ALVCP'][0]
        yrethf.r5alscp = f['R5ALSCP'][0]
        yrethf.ralvdcp = f['RALVDCP'][0]
        yrethf.ralsdcp = f['RALSDCP'][0]
        yrethf.ralfdcp = f['RALFDCP'][0]
        yrethf.rtwat = f['RTWAT'][0]
        yrethf.rtice = f['RTICE'][0]
        yrethf.rticecu = f['RTICECU'][0]
        yrethf.rtwat_rtice_r = f['RTWAT_RTICE_R'][0]
        yrethf.rtwat_rticecu_r = f['RTWAT_RTICECU_R'][0]
        yrethf.rkoop1 = f['RKOOP1'][0]
        yrethf.rkoop2 = f['RKOOP2'][0]

        yrethf.rvtmp2 = 0.0

        klev = f['KLEV'][0]
        pap = np.ascontiguousarray(f['PAP'])
        paph = np.ascontiguousarray(f['PAPH'])
        yrecld.ceta = np.ndarray(order="C", shape=(klev, ))
        yrecld.ceta[:] = pap[0:,0] / paph[klev,0]

        yrephli.lphylin = True

    return yrecldp, yrmcst, yrethf, yrephli, yrecld


def load_reference_fields(path):
    """
    """
    fields = OrderedDict()

    argnames = [
        'PLUDE', 'PCOVPTOT', 'PFPLSL', 'PFPLSN', 'PFHPSL', 'PFHPSN',
        'TENDENCY_LOC_A', 'TENDENCY_LOC_Q', 'TENDENCY_LOC_T', 'TENDENCY_LOC_CLD',
    ]

    with h5py.File(path, 'r') as f:
        for argname in argnames:
            fields[argname.lower()] = np.ascontiguousarray(f[argname])

    return fields
