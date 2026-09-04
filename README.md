# 동아시아 역사 BLOCK QUEST

고등학교 2학년 「동아시아 역사 기행」 수업용 모바일 복습 게임입니다.

## 현재 구현
- 상 → 주·춘추 전국 → 진 → 한 → 남북조 → 수 → 당 → 동아시아 문화권
- 15문항 / 약 10분
- 학번·이름 입력
- 블록·픽셀 탐험 UI
- 정답 즉시 피드백과 핵심 개념 아이템 수집
- 공식 기록 1인 1회
- 순위: 점수 높은 순 → 동점이면 서버 기준 소요시간 짧은 순
- 최종 화면에 본인 현재 순위와 완료 인원만 표시
- 공식 기록 후 연습 모드 가능

## 실시간 순위 활성화
1. Supabase에서 새 프로젝트를 만듭니다.
2. SQL Editor에서 저장소의 `supabase.sql` 전체를 실행합니다.
3. Project Settings > API에서 Project URL과 anon/publishable key를 확인합니다.
4. `config.js`의 두 값을 실제 값으로 교체합니다.

## 학생 링크 만들기
GitHub 저장소 Settings > Pages에서 Source를 `Deploy from a branch`, Branch를 `main` / `(root)`로 선택하고 Save 합니다.
배포가 끝나면 GitHub Pages 주소 하나를 학생 90명에게 공유하면 됩니다.

## 기록 확인
Supabase Table Editor의 `history_attempts`에서 학번, 이름, 점수, 시작·종료 시각, 소요시간, 완료 여부를 확인할 수 있습니다.

## 기록 초기화
다음 반 또는 다음 차시 전에 SQL Editor에서 `truncate table public.history_attempts;`를 실행합니다.

## 수업 설계
역사 문항은 비상교육 『고등학교 동아시아 역사 기행』의 상·주·춘추 전국·진·한·남북조·수·당 및 동아시아 문화권 관련 핵심 내용을 바탕으로 구성했습니다.