import sys
import re

path = "/Users/thanhtung/Downloads/BatApIos/BatApIos/Base.lproj/Main.storyboard"
with open(path, 'r') as f:
    content = f.read()

pattern = re.compile(
    r'(<viewController[^>]*storyboardIdentifier="CourtDetailVC"[^>]*id="([^"]+)"[^>]*>).*?(</viewController>)',
    re.DOTALL
)

match = pattern.search(content)

if not match:
    print("Could not find CourtDetailVC")
    sys.exit(1)

vc_tag = match.group(1)
vc_id = match.group(2)
vc_end_tag = match.group(3)

print("Found VC:", vc_id)

my_inner_xml = """<view key="view" contentMode="scaleToFill" id="VwM-nC-t11">
                        <rect key="frame" x="0.0" y="0.0" width="393" height="852"/>
                        <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                        <subviews>
                            <scrollView clipsSubviews="YES" multipleTouchEnabled="YES" contentMode="scaleToFill" translatesAutoresizingMaskIntoConstraints="NO" id="ScV-wC-t11">
                                <rect key="frame" x="0.0" y="0.0" width="393" height="752"/>
                                <subviews>
                                    <view contentMode="scaleToFill" translatesAutoresizingMaskIntoConstraints="NO" id="CtV-wC-t11">
                                        <rect key="frame" x="0.0" y="0.0" width="393" height="800"/>
                                        <subviews>
                                            <imageView clipsSubviews="YES" userInteractionEnabled="NO" contentMode="scaleAspectFill" horizontalHuggingPriority="251" verticalHuggingPriority="251" translatesAutoresizingMaskIntoConstraints="NO" id="ImV-wC-t11">
                                                <rect key="frame" x="0.0" y="0.0" width="393" height="250"/>
                                                <color key="backgroundColor" systemColor="systemGray5Color"/>
                                                <constraints>
                                                    <constraint firstAttribute="height" constant="250" id="Cn0-0a-001"/>
                                                </constraints>
                                            </imageView>
                                            <stackView opaque="NO" contentMode="scaleToFill" axis="vertical" spacing="12" translatesAutoresizingMaskIntoConstraints="NO" id="StV-wC-t11">
                                                <rect key="frame" x="20" y="270" width="353" height="200"/>
                                                <subviews>
                                                    <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="Sân Cầu Lông Kỳ Hòa" textAlignment="natural" lineBreakMode="tailTruncation" numberOfLines="0" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="LbN-mC-t11">
                                                        <rect key="frame" x="0.0" y="0.0" width="353" height="28.666666"/>
                                                        <fontDescription key="fontDescription" type="boldSystem" pointSize="24"/>
                                                        <nil key="textColor"/>
                                                        <nil key="highlightedColor"/>
                                                    </label>
                                                    <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="150.000đ / Giờ" textAlignment="natural" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="LbP-rC-t11">
                                                        <rect key="frame" x="0.0" y="40.666666" width="353" height="24"/>
                                                        <fontDescription key="fontDescription" type="system" weight="semibold" pointSize="20"/>
                                                        <color key="textColor" systemColor="systemGreenColor"/>
                                                        <nil key="highlightedColor"/>
                                                    </label>
                                                    <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="Sư Vạn Hạnh, Quận 10, TP.HCM" textAlignment="natural" lineBreakMode="tailTruncation" numberOfLines="0" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="LbA-dC-t11">
                                                        <rect key="frame" x="0.0" y="76.666666" width="353" height="17"/>
                                                        <fontDescription key="fontDescription" type="system" pointSize="14"/>
                                                        <color key="textColor" systemColor="secondaryLabelColor"/>
                                                        <nil key="highlightedColor"/>
                                                    </label>
                                                    <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="⭐ 4.8 (120 đánh giá)" textAlignment="natural" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="LbR-tC-t11">
                                                        <rect key="frame" x="0.0" y="105.666666" width="353" height="17"/>
                                                        <fontDescription key="fontDescription" type="system" weight="medium" pointSize="14"/>
                                                        <nil key="textColor"/>
                                                        <nil key="highlightedColor"/>
                                                    </label>
                                                    <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="Giới thiệu chung" textAlignment="natural" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="LbD-iC-t11">
                                                        <rect key="frame" x="0.0" y="134.666666" width="353" height="20.333333"/>
                                                        <fontDescription key="fontDescription" type="system" weight="semibold" pointSize="17"/>
                                                        <nil key="textColor"/>
                                                        <nil key="highlightedColor"/>
                                                    </label>
                                                    <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="Sân thảm chất lượng cao, ánh sáng chuẩn. Khu đỗ xe rộng rãi." textAlignment="natural" lineBreakMode="tailTruncation" numberOfLines="0" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="LbD-fC-t11">
                                                        <rect key="frame" x="0.0" y="167" width="353" height="33"/>
                                                        <fontDescription key="fontDescription" type="system" pointSize="14"/>
                                                        <nil key="textColor"/>
                                                        <nil key="highlightedColor"/>
                                                    </label>
                                                </subviews>
                                            </stackView>
                                            <mapView clipsSubviews="YES" multipleTouchEnabled="YES" contentMode="scaleToFill" translatesAutoresizingMaskIntoConstraints="NO" id="MpV-wC-t11">
                                                <rect key="frame" x="20" y="490" width="353" height="150"/>
                                                <constraints>
                                                    <constraint firstAttribute="height" constant="150" id="Cn0-0a-002"/>
                                                </constraints>
                                                <standardMapConfiguration key="preferredConfiguration"/>
                                            </mapView>
                                        </subviews>
                                        <color key="backgroundColor" systemColor="systemBackgroundColor"/>
                                        <constraints>
                                            <constraint firstItem="ImV-wC-t11" firstAttribute="top" secondItem="CtV-wC-t11" secondAttribute="top" id="Cn0-0a-003"/>
                                            <constraint firstItem="ImV-wC-t11" firstAttribute="leading" secondItem="CtV-wC-t11" secondAttribute="leading" id="Cn0-0a-004"/>
                                            <constraint firstAttribute="trailing" secondItem="ImV-wC-t11" secondAttribute="trailing" id="Cn0-0a-005"/>
                                            <constraint firstItem="StV-wC-t11" firstAttribute="top" secondItem="ImV-wC-t11" secondAttribute="bottom" constant="20" id="Cn0-0a-006"/>
                                            <constraint firstItem="StV-wC-t11" firstAttribute="leading" secondItem="CtV-wC-t11" secondAttribute="leading" constant="20" id="Cn0-0a-007"/>
                                            <constraint firstAttribute="trailing" secondItem="StV-wC-t11" secondAttribute="trailing" constant="20" id="Cn0-0a-008"/>
                                            <constraint firstItem="MpV-wC-t11" firstAttribute="top" secondItem="StV-wC-t11" secondAttribute="bottom" constant="20" id="Cn0-0a-009"/>
                                            <constraint firstItem="MpV-wC-t11" firstAttribute="leading" secondItem="CtV-wC-t11" secondAttribute="leading" constant="20" id="Cn0-0a-010"/>
                                            <constraint firstAttribute="trailing" secondItem="MpV-wC-t11" secondAttribute="trailing" constant="20" id="Cn0-0a-011"/>
                                            <constraint firstAttribute="height" constant="800" id="Cn0-0a-012"/>
                                        </constraints>
                                    </view>
                                </subviews>
                                <constraints>
                                    <constraint firstItem="CtV-wC-t11" firstAttribute="top" secondItem="ScV-wC-t11" secondAttribute="contentLayoutGuide" id="Cn0-0a-013"/>
                                    <constraint firstItem="CtV-wC-t11" firstAttribute="leading" secondItem="ScV-wC-t11" secondAttribute="contentLayoutGuide" id="Cn0-0a-014"/>
                                    <constraint firstItem="CtV-wC-t11" firstAttribute="trailing" secondItem="ScV-wC-t11" secondAttribute="contentLayoutGuide" id="Cn0-0a-015"/>
                                    <constraint firstItem="CtV-wC-t11" firstAttribute="bottom" secondItem="ScV-wC-t11" secondAttribute="contentLayoutGuide" id="Cn0-0a-016"/>
                                    <constraint firstItem="CtV-wC-t11" firstAttribute="width" secondItem="ScV-wC-t11" secondAttribute="frameLayoutGuide" id="Cn0-0a-017"/>
                                </constraints>
                                <viewLayoutGuide key="contentLayoutGuide" id="ClG-uD-111"/>
                                <viewLayoutGuide key="frameLayoutGuide" id="FlG-uD-111"/>
                            </scrollView>
                            <view contentMode="scaleToFill" translatesAutoresizingMaskIntoConstraints="NO" id="BtV-wC-t11">
                                <rect key="frame" x="0.0" y="752" width="393" height="100"/>
                                <subviews>
                                    <button opaque="NO" contentMode="scaleToFill" contentHorizontalAlignment="center" contentVerticalAlignment="center" buttonType="system" lineBreakMode="middleTruncation" translatesAutoresizingMaskIntoConstraints="NO" id="BkB-tC-t11">
                                        <rect key="frame" x="20" y="15" width="353" height="50"/>
                                        <constraints>
                                            <constraint firstAttribute="height" constant="50" id="Cn0-0a-018"/>
                                        </constraints>
                                        <state key="normal" title="Button"/>
                                        <buttonConfiguration key="configuration" style="filled" title="Đặt sân ngay">
                                            <fontDescription key="titleFontDescription" type="boldSystem" pointSize="18"/>
                                            <color key="baseBackgroundColor" systemColor="systemBlueColor"/>
                                        </buttonConfiguration>
                                        <connections>
                                            <action selector="bookNowButtonTapped:" destination="VC_ID_PLACEHOLDER" eventType="touchUpInside"/>
                                        </connections>
                                    </button>
                                </subviews>
                                <color key="backgroundColor" systemColor="systemBackgroundColor"/>
                                <constraints>
                                    <constraint firstAttribute="trailing" secondItem="BkB-tC-t11" secondAttribute="trailing" constant="20" id="Cn0-0a-019"/>
                                    <constraint firstItem="BkB-tC-t11" firstAttribute="leading" secondItem="BtV-wC-t11" secondAttribute="leading" constant="20" id="Cn0-0a-020"/>
                                    <constraint firstItem="BkB-tC-t11" firstAttribute="top" secondItem="BtV-wC-t11" secondAttribute="top" constant="15" id="Cn0-0a-021"/>
                                    <constraint firstAttribute="height" constant="100" id="Cn0-0a-022"/>
                                </constraints>
                            </view>
                            <button opaque="NO" contentMode="scaleToFill" contentHorizontalAlignment="center" contentVerticalAlignment="center" buttonType="system" lineBreakMode="middleTruncation" translatesAutoresizingMaskIntoConstraints="NO" id="BcB-tC-t11">
                                <rect key="frame" x="16" y="59" width="40" height="40"/>
                                <constraints>
                                    <constraint firstAttribute="height" constant="40" id="Cn0-0a-023"/>
                                    <constraint firstAttribute="width" constant="40" id="Cn0-0a-024"/>
                                </constraints>
                                <state key="normal" title="Button"/>
                                <buttonConfiguration key="configuration" style="filled" title="&lt;">
                                    <fontDescription key="titleFontDescription" type="boldSystem" pointSize="20"/>
                                    <color key="baseForegroundColor" white="0.0" alpha="1" colorSpace="custom" customColorSpace="genericGamma22GrayColorSpace"/>
                                    <color key="baseBackgroundColor" white="1" alpha="0.80000000000000004" colorSpace="custom" customColorSpace="genericGamma22GrayColorSpace"/>
                                </buttonConfiguration>
                                <connections>
                                    <action selector="backButtonTapped:" destination="VC_ID_PLACEHOLDER" eventType="touchUpInside"/>
                                </connections>
                            </button>
                        </subviews>
                        <viewLayoutGuide key="safeArea" id="SfA-rC-t11"/>
                        <color key="backgroundColor" systemColor="systemBackgroundColor"/>
                        <constraints>
                            <constraint firstItem="BtV-wC-t11" firstAttribute="leading" secondItem="SfA-rC-t11" secondAttribute="leading" id="Cn0-0a-025"/>
                            <constraint firstItem="BtV-wC-t11" firstAttribute="trailing" secondItem="SfA-rC-t11" secondAttribute="trailing" id="Cn0-0a-026"/>
                            <constraint firstAttribute="bottom" secondItem="BtV-wC-t11" secondAttribute="bottom" id="Cn0-0a-027"/>
                            <constraint firstItem="ScV-wC-t11" firstAttribute="top" secondItem="VwM-nC-t11" secondAttribute="top" id="Cn0-0a-028"/>
                            <constraint firstItem="ScV-wC-t11" firstAttribute="leading" secondItem="SfA-rC-t11" secondAttribute="leading" id="Cn0-0a-029"/>
                            <constraint firstItem="BtV-wC-t11" firstAttribute="top" secondItem="ScV-wC-t11" secondAttribute="bottom" id="Cn0-0a-030"/>
                            <constraint firstItem="ScV-wC-t11" firstAttribute="trailing" secondItem="SfA-rC-t11" secondAttribute="trailing" id="Cn0-0a-031"/>
                            <constraint firstItem="BcB-tC-t11" firstAttribute="top" secondItem="SfA-rC-t11" secondAttribute="top" id="Cn0-0a-032"/>
                            <constraint firstItem="BcB-tC-t11" firstAttribute="leading" secondItem="SfA-rC-t11" secondAttribute="leading" constant="16" id="Cn0-0a-033"/>
                        </constraints>
                    </view>
                    <connections>
                        <outlet property="addressLabel" destination="LbA-dC-t11" id="CnN-cC-t01"/>
                        <outlet property="courtImageView" destination="ImV-wC-t11" id="CnN-cC-t02"/>
                        <outlet property="courtNameLabel" destination="LbN-mC-t11" id="CnN-cC-t03"/>
                        <outlet property="descriptionLabel" destination="LbD-fC-t11" id="CnN-cC-t04"/>
                        <outlet property="mapView" destination="MpV-wC-t11" id="CnN-cC-t05"/>
                        <outlet property="priceLabel" destination="LbP-rC-t11" id="CnN-cC-t06"/>
                        <outlet property="ratingLabel" destination="LbR-tC-t11" id="CnN-cC-t07"/>
                    </connections>"""

my_inner_xml = my_inner_xml.replace('VC_ID_PLACEHOLDER', vc_id)

new_content = content[:match.start()] + vc_tag + "\n" + my_inner_xml + "\n" + vc_end_tag + content[match.end():]

with open(path, 'w') as f:
    f.write(new_content)

print(f"Re-injected successfully into existing {vc_id}")
