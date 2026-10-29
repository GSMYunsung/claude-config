#!/usr/bin/env python3
"""Flags scenario patterns that made past runs fail, before spending minutes on a run.

Usage: lint-flows.py [.maestro]        (run.sh calls it; exit 1 when anything is found)

Each rule is a failure class seen in real runs. A finding means "this step depends on timing,
a tool default, or data the scenario did not create" — fix it at the layer named in the message,
not by adding waits or optional taps.
"""
import glob, os, re, sys

root = sys.argv[1] if len(sys.argv) > 1 else '.maestro'
WAIT = re.compile(r'^- (extendedWaitUntil|assertVisible)\b')
TAP = re.compile(r'^- tapOn:\s*(.*)$')
TAB = re.compile(r', tab')

findings = []


def add(path, line_no, rule, msg):
    findings.append(f'{os.path.relpath(path)}:{line_no}  [{rule}] {msg}')


def steps(lines):
    """Top-level steps: (line_no, text of the step including its indented body)."""
    out, cur, start = [], [], 0
    for i, line in enumerate(lines, 1):
        if line.startswith('- '):
            if cur:
                out.append((start, cur))
            cur, start = [line], i
        elif cur and (line.startswith(' ') or not line.strip()):
            cur.append(line)
        elif cur:
            out.append((start, cur)); cur = []
    if cur:
        out.append((start, cur))
    return out


for path in sorted(glob.glob(os.path.join(root, 'flows', '*.yaml'))):
    text = open(path, encoding='utf-8').read()
    lines = text.split('\n')
    body = text.split('\n---\n', 1)[1] if '\n---\n' in text else text
    header = text.split('\n---\n', 1)[0]

    if not re.search(r'^#\s*(전제|requires)\s*:', header, re.M) or not re.search(r'^#\s*(남김|leaves)\s*:', header, re.M):
        add(path, 1, 'state-contract', '머리에 "# 전제:"와 "# 남김:"이 없다 → 앞 시나리오에서 받는 상태와 뒤에 남기는 상태(데이터 포함)를 적는다')

    st = steps(lines)
    for idx, (no, block) in enumerate(st):
        first = block[0]
        joined = '\n'.join(block)

        if first.startswith('- launchApp') and 'permissions:' not in joined:
            add(path, no, 'launch-permissions', 'launchApp은 기본으로 모든 권한을 허용한다 → permissions:를 명시한다(예: { all: allow } 또는 location: unset)')

        if 'retryTapIfNoChange' in joined:
            add(path, no, 'retry-tap', 'retryTapIfNoChange는 애니메이션·전환 중엔 "바뀌었다"고 오판한다 → tap-tab / tap-until')

        if first.startswith('- repeat') and 'while:' not in joined:
            add(path, no, 'fixed-repeat', '고정 횟수 반복은 창이 뜨는 시점에 기대고 있다 → while 조건(목표가 보일 때까지) 또는 공통 흐름')

        m = TAP.match(first)
        if not m:
            continue
        target = m.group(1) or next((l.split('text:', 1)[1] for l in block[1:] if 'text:' in l), '')
        if 'optional: true' in joined:
            continue
        if TAB.search(target):
            add(path, no, 'tab-tap', '하단 탭을 tapOn으로 누른다 → subflows/tap-tab.yaml')
            continue
        nxt = st[idx + 1][1][0] if idx + 1 < len(st) else ''
        if nxt.startswith('- extendedWaitUntil'):
            add(path, no, 'nav-tap', '누른 뒤 다음 화면을 기다린다(화면 전환) → subflows/tap-until.yaml (TAP, UNTIL)로 "그 화면이 보일 때까지" 누른다')

if findings:
    print(f'lint-flows: {len(findings)}개 — 과거 실패 패턴 (SKILL.md "실패를 시나리오에서 고치지 않기")')
    print('\n'.join(findings))
    sys.exit(1)
print('lint-flows: ok')
