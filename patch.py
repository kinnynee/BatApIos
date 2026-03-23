import re

file_path = "/Users/thanhtung/Desktop/BatApIos/BatApIos/Base.lproj/Main.storyboard"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# 1. Change initialViewController to TabBarController
content = re.sub(r'initialViewController="[^"]+"', 'initialViewController="main-tab-bar-controller"', content, count=1)

# 2. Add UITabBarController scene before </scenes>
tab_bar_scene = """
        <!--Main Tab Bar Controller-->
        <scene sceneID="main-tab-scene">
            <objects>
                <tabBarController storyboardIdentifier="MainTabBarVC" id="main-tab-bar-controller" sceneMemberID="viewController">
                    <tabBar key="tabBar" contentMode="scaleToFill" insetsLayoutMarginsFromSafeArea="NO" id="main-tab-bar">
                        <rect key="frame" x="0.0" y="0.0" width="393" height="49"/>
                        <autoresizingMask key="autoresizingMask"/>
                        <color key="backgroundColor" white="0.0" alpha="0.0" colorSpace="custom" customColorSpace="genericGamma22GrayColorSpace"/>
                    </tabBar>
                    <connections>
                        <segue destination="home2-vc-main" kind="relationship" relationship="viewControllers" id="seg-t-hm"/>
                        <segue destination="ncb-vc-main" kind="relationship" relationship="viewControllers" id="seg-t-bk"/>
                        <segue destination="gvW-iY-v1z" kind="relationship" relationship="viewControllers" id="seg-t-hs"/>
                        <segue destination="prof-vc-main" kind="relationship" relationship="viewControllers" id="seg-t-pf"/>
                    </connections>
                </tabBarController>
                <placeholder placeholderIdentifier="IBFirstResponder" id="tab-first-responder" userLabel="First Responder" customClass="UIResponder" sceneMemberID="firstResponder"/>
            </objects>
            <point key="canvasLocation" x="-1000" y="-1000"/>
        </scene>
"""
if 'id="main-tab-bar-controller"' not in content:
    content = content.replace("</scenes>", tab_bar_scene + "    </scenes>")

# Helper function to inject things into a VC
def inject_into_vc(vc_id, text_to_inject, content):
    pattern = r'(<(?:viewController|tableViewController) [^>]*?id="' + vc_id + r'".*?)(</(?:viewController|tableViewController)>)'
    def replacer(match):
        inner = match.group(1)
        if text_to_inject.strip() not in inner:
            return inner + "\n" + text_to_inject + "\n                    " + match.group(2)
        return match.group(0)
    return re.sub(pattern, replacer, content, flags=re.DOTALL)

def inject_segue(vc_id, destination_id, kind, identifier, segue_id, content, extra_attrs=""):
    segue_element = f'<segue destination="{destination_id}" kind="{kind}" identifier="{identifier}" id="{segue_id}" {extra_attrs}/>'
    pattern = r'(<(?:viewController|tableViewController) [^>]*?id="' + vc_id + r'".*?)(</(?:viewController|tableViewController)>)'
    def replacer(match):
        inner = match.group(1)
        if f'identifier="{identifier}"' in inner:
            return match.group(0) # Already exists
        
        if '<connections>' in inner:
            inner = re.sub(r'(<connections>)', r'\1\n                        ' + segue_element, inner, count=1)
            return inner + match.group(2)
        else:
            connections_block = "\n                    <connections>\n                        " + segue_element + "\n                    </connections>"
            return inner + connections_block + "\n                " + match.group(2)
    return re.sub(pattern, replacer, content, flags=re.DOTALL)

# Insert tabBarItems
home_tab = '<tabBarItem key="tabBarItem" title="Trang chủ" image="house.fill" catalog="system" id="tab-h-1"/>'
book_tab = '<tabBarItem key="tabBarItem" title="Đặt sân" image="plus.circle.fill" catalog="system" id="tab-b-1"/>'
hist_tab = '<tabBarItem key="tabBarItem" title="Lịch sử" image="clock.fill" catalog="system" id="tab-p-1"/>'
prof_tab = '<tabBarItem key="tabBarItem" title="Cá nhân" image="person.fill" catalog="system" id="tab-pr-1"/>'

content = inject_into_vc("home2-vc-main", "                    " + home_tab, content)
content = inject_into_vc("ncb-vc-main", "                    " + book_tab, content)
content = inject_into_vc("gvW-iY-v1z", "                    " + hist_tab, content)
content = inject_into_vc("prof-vc-main", "                    " + prof_tab, content)

# Inject segues
content = inject_segue("home2-vc-main", "ntf-vc-main", "show", "showNotifications", "seg-h-ntf", content)
content = inject_segue("prof-vc-main", "change-vc", "show", "showChangePassword", "seg-pr-chg", content)
content = inject_segue("prof-vc-main", "abt-vc-main", "show", "showAbout", "seg-pr-abt", content)
content = inject_segue("prof-vc-main", "BYZ-38-t0r", "presentation", "logout", "seg-pr-out", content, 'modalPresentationStyle="fullScreen" modalTransitionStyle="crossDissolve"')

content = inject_segue("ncb-vc-main", "calendar-vc", "show", "showCalendar", "seg-ncb-cal", content)
content = inject_segue("ncb-vc-main", "payment-vc", "show", "showPaymentMethod", "seg-ncb-pay", content)
content = inject_segue("payment-vc", "chk-vc-main", "show", "showCheckout", "seg-pay-chk", content)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Storyboard patched successfully.")
