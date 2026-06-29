package com.liu.xiaomibandunlock

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import android.widget.Toast
import com.liu.xiaomibandunlock.ui.theme.XiaomiBandUnlockClacTheme
import java.security.MessageDigest

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            XiaomiBandUnlockClacTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    UnlockCalculator(
                        modifier = Modifier.padding(innerPadding)
                    )
                }
            }
        }
    }
}

@Composable
fun UnlockCalculator(modifier: Modifier = Modifier) {
    var input1 by remember { mutableStateOf("") }
    var input2 by remember { mutableStateOf("") }
    var useNewAlgorithm by remember { mutableStateOf(false) }
    
    val focusManager = LocalFocusManager.current
    
    val result = remember(input1, input2, useNewAlgorithm) {
        try {
            val mac = input1.uppercase().replace(Regex("[^0-9A-F]"), "")
            val sn = input2.trim().uppercase()
            
            if (mac.length == 12 && sn.isNotEmpty()) {
                val dataStr = if (useNewAlgorithm) {
                    sn + mac + "XIAOMI"
                } else {
                    mac + sn + "XIAOMI"
                }
                
                val hash = MessageDigest.getInstance("SHA-256").digest(dataStr.toByteArray())
                (0 until 10).joinToString("") { i ->
                    ((hash[i].toInt() and 0xFF) % 10).toString()
                }
            } else {
                ""
            }
        } catch (e: Exception) {
            ""
        }
    }

    Column(
        modifier = modifier
            .fillMaxSize()
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null
            ) { focusManager.clearFocus() }
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "小米环表解锁工具",
            style = MaterialTheme.typography.headlineLarge,
            modifier = Modifier.padding(vertical = 32.dp)
        )

        Text(text = "设备 MAC 地址", modifier = Modifier.padding(bottom = 4.dp))
        TextField(
            value = input1,
            onValueChange = { input1 = it },
            singleLine = true,
            placeholder = { Text("例如: 00:11:22:33:44:55") },
            modifier = Modifier.padding(bottom = 16.dp)
        )

        Text(text = "设备 SN 序列号", modifier = Modifier.padding(bottom = 4.dp))
        TextField(
            value = input2,
            onValueChange = { input2 = it },
            singleLine = true,
            placeholder = { Text("例如: ABCDE/1234567890") }
        )

        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.padding(top = 16.dp)
        ) {
            Text(text = "使用新算法", modifier = Modifier.padding(end = 8.dp))
            Switch(
                checked = useNewAlgorithm,
                onCheckedChange = { useNewAlgorithm = it }
            )
        }

        Text(
            text = "新算法为S5和10Pro及以后的设备打造",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(top = 4.dp)
        )

        if (result.isNotEmpty()) {
            val clipboardManager = LocalClipboardManager.current
            val context = LocalContext.current
            val isSuccess = result.length == 10
            
            Card(
                modifier = Modifier
                    .padding(top = 32.dp)
                    .fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = if (isSuccess) 
                        MaterialTheme.colorScheme.primaryContainer 
                    else 
                        MaterialTheme.colorScheme.errorContainer
                ),
                elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
            ) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.padding(24.dp).fillMaxWidth()
                ) {
                    Text(
                        text = if (isSuccess) "计算成功 - 解锁码" else "计算失败",
                        style = MaterialTheme.typography.labelMedium,
                        color = if (isSuccess) 
                            MaterialTheme.colorScheme.onPrimaryContainer 
                        else 
                            MaterialTheme.colorScheme.onErrorContainer
                    )
                    
                    Spacer(modifier = Modifier.height(12.dp))
                    
                    Text(
                        text = result,
                        style = MaterialTheme.typography.displayMedium.copy(
                            fontFamily = FontFamily.Monospace,
                            fontWeight = FontWeight.ExtraBold,
                            letterSpacing = 2.sp
                        ),
                        color = if (isSuccess) 
                            MaterialTheme.colorScheme.primary 
                        else 
                            MaterialTheme.colorScheme.error
                    )
                    
                    if (isSuccess) {
                        Spacer(modifier = Modifier.height(16.dp))
                        Button(
                            onClick = {
                                clipboardManager.setText(AnnotatedString(result))
                                Toast.makeText(context, "解锁码已复制", Toast.LENGTH_SHORT).show()
                            },
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text("复制到剪贴板")
                        }
                    }
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun UnlockCalculatorPreview() {
    XiaomiBandUnlockClacTheme {
        UnlockCalculator()
    }
}
