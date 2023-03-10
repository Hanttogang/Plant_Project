#!/usr/bin/env bash

#자주 사용하는 값 변수에 저장
REPOSITORY=/home/ec2-user/projects
APP_NAME=Plant_Project

#git clone 받은 위치로 이동
cd $REPOSITORY/$APP_NAME/

# master 브랜치의 최신 내용 받기
echo "> Git Pull"
git pull

# gradle 권한 부여
chmod +x ./gradlew

# build 수행
echo "> project build start"
./gradlew build

echo "> directory로 이동"
cd $REPOSITORY

# build의 결과물 (jar 파일) 특정 위치로 복사
echo "> build 파일 복사"
cp $REPOSITORY/$APP_NAME/build/libs/*.jar $REPOSITORY/

echo "> 현재 구동중인 애플리케이션 pid 확인"
CURRENT_PID=$(pgrep -f ${PROJECT_NAME}.*.jar)

echo "> 현재 구동중인 애플리케이션 pid: $CURRENT_PID"
if [ -z "$CURRENT_PID" ]; then
	echo "> 현재 구동중인 애플리케이션이 없으므로 종료하지 않습니다."
else
	echo "> kill -15 $CURRENT_PID"
	kill -15 $CURRENT_PID
	sleep 5
fi

echo "> 새 애플리케이션 배포"
JAR_NAME=$(ls -tr $REPOSITORY/ | grep jar | tail -n 1)

echo "> $JAR_NAME 에 실행권한 추가"
chmod +x $JAR_NAME

echo "> Jar Name: $JAR_NAME"
nohup java -jar $REPOSITORY/$JAR_NAME > $REPOSITORY/nohup.out 2>&1 &
