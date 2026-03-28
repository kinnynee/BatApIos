import sys

path = "/Users/thanhtung/Downloads/BatApIos/BatApIos/Base.lproj/Main.storyboard"
with open(path, 'r') as f:
    content = f.read()

bad_xml = """
        <!--Court Detail View Controller-->
        <scene sceneID="CourtDetailScene">
            <objects>
                <viewController storyboardIdentifier="CourtDetailVC" id="CourtDetailVC_ID" customClass="CourtDetailViewController" customModule="BatApIos" customModuleProvider="target" sceneMemberID="viewController">
                    <view key="view" contentMode="scaleToView" id="CourtDetailView">
                        <rect key="frame" x="0.0" y="0.0" width="393" height="852"/>
                        <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                        <subviews>
                            <scrollView clipsSubviews="YES" multipleTouchEnabled="YES" contentMode="scaleToView" insetsLayoutMarginsFromSafeArea="NO" translatesAutoresizingMaskIntoConstraints="NO" id="CD_ScrollView">
                                <rect key="frame" x="0.0" y="0.0" width="393" height="752"/>
                                <subviews>
                                    <view contentMode="scaleToView" translatesAutoresizingMaskIntoConstraints="NO" id="CD_ContentView">
                                        <rect key="frame" x="0.0" y="0.0" width="393" height="800"/>
                                        <subviews>
                                            <imageView clipsSubviews="YES" userInteractionEnabled="NO" contentMode="scaleAspectFill" horizontalHuggingPriority="251" verticalHuggingPriority="251" translatesAutoresizingMaskIntoConstraints="NO" id="CD_ImageView">
                                                <rect key="frame" x="0.0" y="0.0" width="393" height="250"/>
                                                <color key="backgroundColor" systemColor="systemGray5Color"/>
                                                <constraints>
                                                    <constraint firstAttribute="height" constant="250" id="CD_Img_Height"/>
                                                </constraints>
                                            </imageView>
                                            <stackView opaque="NO" contentMode="scaleToView" axis="vertical" spacing="12" translatesAutoresizingMaskIntoConstraints="NO" id="CD_MainStack">
                                                <rect key="frame" x="20" y="270" width="353" height="200"/>
                                                <subviews>
                                                    <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="Sân Cầu Lông Kỳ Hòa" textAlignment="natural" lineBreakMode="tailTruncation" numberOfLines="0" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="CD_NameLabel">
                                                        <rect key="frame" x="0.0" y="0.0" width="353" height="28.66666"/>
                                                        <fontDescription key="fontDescription" type="boldSystem" pointSize="24"/>
                                                        <nil key="textColor"/>
                                                        <nil key="highlightedColor"/>
                                                    </label>
                                                    <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="150.000đ / Giờ" textAlignment="natural" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="CD_PriceLabel">
                                                        <rect key="frame" x="0.0" y="40.66666" width="353" height="24"/>
                                                        <fontDescription key="fontDescription" type="system" weight="semibold" pointSize="20"/>
                                                        <color key="textColor" systemColor="systemGreenColor"/>
                                                        <nil key="highlightedColor"/>
                                                    </label>
                                                    <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="Sư Vạn Hạnh, Quận 10, TP.HCM" textAlignment="natural" lineBreakMode="tailTruncation" numberOfLines="0" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="CD_AddressLabel">
                                                        <rect key="frame" x="0.0" y="76.6666" width="353" height="17"/>
                                                        <fontDescription key="fontDescription" type="system" pointSize="14"/>
                                                        <color key="textColor" systemColor="secondaryLabelColor"/>
                                                        <nil key="highlightedColor"/>
                                                    </label>
                                                    <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="⭐ 4.8 (120 đánh giá)" textAlignment="natural" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="CD_RatingLabel">
                                                        <rect key="frame" x="0.0" y="105.6666" width="353" height="17"/>
                                                        <fontDescription key="fontDescription" type="system" weight="medium" pointSize="14"/>
                                                        <nil key="textColor"/>
                                                        <nil key="highlightedColor"/>
                                                    </label>
                                                    <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="Giới thiệu chung" textAlignment="natural" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="CD_DescTitleLabel">
                                                        <rect key="frame" x="0.0" y="134.6666" width="353" height="20.3333"/>
                                                        <fontDescription key="fontDescription" type="system" weight="semibold" pointSize="17"/>
                                                        <nil key="textColor"/>
                                                        <nil key="highlightedColor"/>
                                                    </label>
                                                    <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="Sân thảm chất lượng cao. Khu vực đỗ xe rộng rãi." textAlignment="natural" lineBreakMode="tailTruncation" numberOfLines="0" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="CD_DescLabel">
                                                        <rect key="frame" x="0.0" y="167" width="353" height="33"/>
                                                        <fontDescription key="fontDescription" type="system" pointSize="14"/>
                                                        <nil key="textColor"/>
                                                        <nil key="highlightedColor"/>
                                                    </label>
                                                </subviews>
                                            </stackView>
                                            <mapView clipsSubviews="YES" multipleTouchEnabled="YES" contentMode="scaleToView" translatesAutoresizingMaskIntoConstraints="NO" id="CD_MapView">
                                                <rect key="frame" x="20" y="490" width="353" height="150"/>
                                                <constraints>
                                                    <constraint firstAttribute="height" constant="150" id="CD_Map_Height"/>
                                                </constraints>
                                                <standardMapConfiguration key="preferredConfiguration"/>
                                            </mapView>
                                        </subviews>
                                        <color key="backgroundColor" systemColor="systemBackgroundColor"/>
                                        <constraints>
                                            <constraint firstItem="CD_ImageView" firstAttribute="top" secondItem="CD_ContentView" secondAttribute="top" id="CD_Img_Top"/>
                                            <constraint firstItem="CD_ImageView" firstAttribute="leading" secondItem="CD_ContentView" secondAttribute="leading" id="CD_Img_Leading"/>
                                            <constraint firstAttribute="trailing" secondItem="CD_ImageView" secondAttribute="trailing" id="CD_Img_Trailing"/>
                                            <constraint firstItem="CD_MainStack" firstAttribute="top" secondItem="CD_ImageView" secondAttribute="bottom" constant="20" id="CD_Stack_Top"/>
                                            <constraint firstItem="CD_MainStack" firstAttribute="leading" secondItem="CD_ContentView" secondAttribute="leading" constant="20" id="CD_Stack_Lead"/>
                                            <constraint firstAttribute="trailing" secondItem="CD_MainStack" secondAttribute="trailing" constant="20" id="CD_Stack_Trail"/>
                                            <constraint firstItem="CD_MapView" firstAttribute="top" secondItem="CD_MainStack" secondAttribute="bottom" constant="20" id="CD_Map_Top"/>
                                            <constraint firstItem="CD_MapView" firstAttribute="leading" secondItem="CD_ContentView" secondAttribute="leading" constant="20" id="CD_Map_Lead"/>
                                            <constraint firstAttribute="trailing" secondItem="CD_MapView" secondAttribute="trailing" constant="20" id="CD_Map_Trail"/>
                                            <constraint firstAttribute="height" constant="800" id="CD_Content_Height"/>
                                        </constraints>
                                    </view>
                                </subviews>
                                <constraints>
                                    <constraint firstItem="CD_ContentView" firstAttribute="top" secondItem="CD_ScrollView" secondAttribute="top" id="CD_S_Top"/>
                                    <constraint firstItem="CD_ContentView" firstAttribute="leading" secondItem="CD_ScrollView" secondAttribute="leading" id="CD_S_Lead"/>
                                    <constraint firstItem="CD_ContentView" firstAttribute="trailing" secondItem="CD_ScrollView" secondAttribute="trailing" id="CD_S_Trail"/>
                                    <constraint firstItem="CD_ContentView" firstAttribute="bottom" secondItem="CD_ScrollView" secondAttribute="bottom" id="CD_S_Bot"/>
                                    <constraint firstItem="CD_ContentView" firstAttribute="width" secondItem="CD_ScrollView" secondAttribute="width" id="CD_S_Width"/>
                                </constraints>
                            </scrollView>
                            <view contentMode="scaleToView" translatesAutoresizingMaskIntoConstraints="NO" id="CD_BottomView">
                                <rect key="frame" x="0.0" y="752" width="393" height="100"/>
                                <subviews>
                                    <button opaque="NO" contentMode="scaleToView" contentHorizontalAlignment="center" contentVerticalAlignment="center" buttonType="system" lineBreakMode="middleTruncation" translatesAutoresizingMaskIntoConstraints="NO" id="CD_BookButton">
                                        <rect key="frame" x="20" y="15" width="353" height="50"/>
                                        <constraints>
                                            <constraint firstAttribute="height" constant="50" id="CD_Btn_Height"/>
                                        </constraints>
                                        <state key="normal" title="Button"/>
                                        <buttonConfiguration key="configuration" style="filled" title="Đặt sân ngay">
                                            <fontDescription key="titleFontDescription" type="boldSystem" pointSize="18"/>
                                            <color key="baseBackgroundColor" systemColor="systemBlueColor"/>
                                        </buttonConfiguration>
                                        <connections>
                                            <action selector="bookNowButtonTapped:" destination="CourtDetailVC_ID" eventType="touchUpInside"/>
                                        </connections>
                                    </button>
                                </subviews>
                                <color key="backgroundColor" systemColor="systemBackgroundColor"/>
                                <constraints>
                                    <constraint firstAttribute="trailing" secondItem="CD_BookButton" secondAttribute="trailing" constant="20" id="CD_Bottom_Trail"/>
                                    <constraint firstItem="CD_BookButton" firstAttribute="leading" secondItem="CD_BottomView" secondAttribute="leading" constant="20" id="CD_Bottom_Lead"/>
                                    <constraint firstItem="CD_BookButton" firstAttribute="top" secondItem="CD_BottomView" secondAttribute="top" constant="15" id="CD_Bottom_Top"/>
                                    <constraint firstAttribute="height" constant="100" id="CD_Bottom_Height"/>
                                </constraints>
                            </view>
                            <button opaque="NO" contentMode="scaleToView" contentHorizontalAlignment="center" contentVerticalAlignment="center" buttonType="system" lineBreakMode="middleTruncation" translatesAutoresizingMaskIntoConstraints="NO" id="CD_BackButton">
                                <rect key="frame" x="16" y="59" width="40" height="40"/>
                                <constraints>
                                    <constraint firstAttribute="height" constant="40" id="CD_Back_H"/>
                                    <constraint firstAttribute="width" constant="40" id="CD_Back_W"/>
                                </constraints>
                                <state key="normal" title="Button"/>
                                <buttonConfiguration key="configuration" style="filled" title="&lt;">
                                    <fontDescription key="titleFontDescription" type="boldSystem" pointSize="20"/>
                                    <color key="baseForegroundColor" white="0.0" alpha="1" colorSpace="custom" customColorSpace="genericGamma22GrayColorSpace"/>
                                    <color key="baseBackgroundColor" white="1" alpha="0.8" colorSpace="custom" customColorSpace="genericGamma22GrayColorSpace"/>
                                    <userDefinedRuntimeAttributes>
                                        <userDefinedRuntimeAttribute type="number" keyPath="layer.cornerRadius">
                                            <integer key="value" value="20"/>
                                        </userDefinedRuntimeAttribute>
                                    </userDefinedRuntimeAttributes>
                                </buttonConfiguration>
                                <connections>
                                    <action selector="backButtonTapped:" destination="CourtDetailVC_ID" eventType="touchUpInside"/>
                                </connections>
                            </button>
                        </subviews>
                        <viewLayoutGuide key="safeArea" id="CD_SafeArea"/>
                        <color key="backgroundColor" systemColor="systemBackgroundColor"/>
                        <constraints>
                            <constraint firstItem="CD_BottomView" firstAttribute="leading" secondItem="CD_SafeArea" secondAttribute="leading" id="CD_Main_BotLead"/>
                            <constraint firstItem="CD_BottomView" firstAttribute="trailing" secondItem="CD_SafeArea" secondAttribute="trailing" id="CD_Main_BotTrail"/>
                            <constraint firstAttribute="bottom" secondItem="CD_BottomView" secondAttribute="bottom" id="CD_Main_BotBot"/>
                            <constraint firstItem="CD_ScrollView" firstAttribute="top" secondItem="CourtDetailView" secondAttribute="top" id="CD_Main_ScrollTop"/>
                            <constraint firstItem="CD_ScrollView" firstAttribute="leading" secondItem="CD_SafeArea" secondAttribute="leading" id="CD_Main_ScrollLead"/>
                            <constraint firstItem="CD_BottomView" firstAttribute="top" secondItem="CD_ScrollView" secondAttribute="bottom" id="CD_Main_ScrollBot"/>
                            <constraint firstItem="CD_ScrollView" firstAttribute="trailing" secondItem="CD_SafeArea" secondAttribute="trailing" id="CD_Main_ScrollTrail"/>
                            <constraint firstItem="CD_BackButton" firstAttribute="top" secondItem="CD_SafeArea" secondAttribute="top" id="CD_Main_BackTop"/>
                            <constraint firstItem="CD_BackButton" firstAttribute="leading" secondItem="CD_SafeArea" secondAttribute="leading" constant="16" id="CD_Main_BackLead"/>
                        </constraints>
                    </view>
                    <connections>
                        <outlet property="addressLabel" destination="CD_AddressLabel" id="CD_Conn_Address"/>
                        <outlet property="courtImageView" destination="CD_ImageView" id="CD_Conn_Img"/>
                        <outlet property="courtNameLabel" destination="CD_NameLabel" id="CD_Conn_Name"/>
                        <outlet property="descriptionLabel" destination="CD_DescLabel" id="CD_Conn_Desc"/>
                        <outlet property="mapView" destination="CD_MapView" id="CD_Conn_Map"/>
                        <outlet property="priceLabel" destination="CD_PriceLabel" id="CD_Conn_Price"/>
                        <outlet property="ratingLabel" destination="CD_RatingLabel" id="CD_Conn_Rating"/>
                    </connections>
                </viewController>
                <placeholder placeholderIdentifier="IBFirstResponder" id="CD_FirstResponder" userLabel="First Responder" customClass="UIResponder" sceneMemberID="firstResponder"/>
            </objects>
            <point key="canvasLocation" x="7000" y="0.0"/>
        </scene>
"""
if bad_xml in content:
    content = content.replace(bad_xml, "")
    with open(path, 'w') as f:
        f.write(content)
    print("Reverted successfully")
else:
    # If the exact match fails due to trailing spaces, let's use regex
    import re
    # Remove from <scene sceneID="CourtDetailScene"> up to </scene>
    pattern = re.compile(r'<!--Court Detail View Controller-->\s*<scene sceneID="CourtDetailScene">.*?</scene>', re.DOTALL)
    new_content, count = re.subn(pattern, '', content)
    if count > 0:
        with open(path, 'w') as f:
            f.write(new_content)
        print("Reverted successfully via regex")
    else:
        print("Could not find the block to revert.")

