<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원가입</title>
<style>
    body { font-family: 'Segoe UI', sans-serif; text-align: center; background-color: #f4f6f9; padding-top: 50px; }
    .container { width: 400px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); text-align: left; }
    h2 { margin-top: 0; text-align: center; color: #333; }
    
    label { display: block; margin-top: 15px; font-weight: bold; font-size: 14px; }
    input, select { width: 100%; padding: 10px; margin-top: 5px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
    
    button { width: 100%; padding: 12px; margin-top: 25px; background-color: #28a745; color: white; border: none; border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 16px; }
    button:hover { background-color: #218838; }
    
    .link-area { text-align: center; margin-top: 15px; font-size: 13px; }
    a { text-decoration: none; color: #007bff; }
</style>
<script>
    function toggleOptions() {
        var role = document.getElementById("role").value;
        var deptSelect = document.getElementById("dept");
        var adminAuthDiv = document.getElementById("adminAuthDiv");
        
        if (role === "Admin") {
            deptSelect.value = "Administration";
            for (var i=0; i<deptSelect.options.length; i++) {
                if(deptSelect.options[i].value !== "Administration") deptSelect.options[i].disabled = true;
            }
            adminAuthDiv.style.display = "block";
            document.getElementById("adminCode").required = true;
        } else {
            deptSelect.value = "";
            for (var i=0; i<deptSelect.options.length; i++) {
                deptSelect.options[i].disabled = false;
            }
            adminAuthDiv.style.display = "none";
            document.getElementById("adminCode").required = false;
            document.getElementById("adminCode").value = "";
        }
    }

    function validateForm() {
        var phone = document.forms["regForm"]["phone"].value;
        var phonePattern = /^010-\d{4}-\d{4}$/;
        
        if (!phonePattern.test(phone)) {
            alert("전화번호 형식이 올바르지 않습니다.");
            return false;
        }
        return true;
    }

    function autoHyphen(target) {
        var number = target.value.replace(/[^0-9]/g, "");
        var phone = "";

        if(number.length < 4) {
            phone = number;
        } else if(number.length < 8) {
            phone += number.substr(0, 3);
            phone += "-";
            phone += number.substr(3);
        } else {
            phone += number.substr(0, 3);
            phone += "-";
            phone += number.substr(3, 4);
            phone += "-";
            phone += number.substr(7);
        }
        target.value = phone;
    }
</script>
</head>
<body>

    <div class="container">
        <h2>📝 회원가입</h2>
        
        <form name="regForm" action="register_action.jsp" method="post" onsubmit="return validateForm()">
            
            <label>역할 (Role)</label>
            <select name="role" id="role" required onchange="toggleOptions()">
                <option value="Student">학생 (Student)</option>
                <option value="Professor">교수 (Professor)</option>
                <option value="Staff">직원 (Staff)</option>
                <option value="Admin">관리자 (Admin)</option>
            </select>
            
            <div id="adminAuthDiv" style="display:none; background:#fff3cd; padding:10px; border-radius:5px; margin-top:10px;">
                <label style="margin-top:0; color:#856404;">🔑 관리자 가입 승인 코드</label>
                <input type="password" name="adminCode" id="adminCode" placeholder="기존 관리자에게 받은 코드 입력">
            </div>
            
            <label>학과 (Department)</label>
            <select name="dept" id="dept" required>
                <option value="">-- 학과 선택 --</option>
                <option value="Computer Science">Computer Science</option>
                <option value="Electronic Eng">Electronic Eng</option>
                <option value="Mechanical Eng">Mechanical Eng</option>
                <option value="Business Admin">Business Admin</option>
                <option value="English Lit">English Lit</option>
                <option value="Physics">Physics</option>
                <option value="Administration" style="display:none;">Administration (관리본부)</option>
            </select>

            <label>아이디</label>
            <input type="text" name="id" required placeholder="학번 또는 사번">

            <label>비밀번호</label>
            <input type="password" name="pw" required placeholder="비밀번호 입력">

            <label>이름</label>
            <input type="text" name="name" required placeholder="성명">

            <label>전화번호</label>
            <input type="text" name="phone" oninput="autoHyphen(this)" maxlength="13" required placeholder="숫자만 입력 (예: 01012345678)">
            
            <button type="submit">가입하기</button>
        </form>
        
        <div class="link-area">
            이미 계정이 있으신가요? <a href="login.jsp">로그인하러 가기</a>
        </div>
    </div>

</body>
</html>